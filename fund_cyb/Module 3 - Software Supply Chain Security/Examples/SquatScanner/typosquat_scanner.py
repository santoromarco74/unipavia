from rapidfuzz.distance import Levenshtein
import subprocess

def mutate_package(pkg):
    # Return a list of typo variants (e.g., with edit distance 1)
    mutations = set()
    for i in range(len(pkg)):
        mutations.add(pkg[:i] + pkg[i+1:])  # deletion
        for c in 'abcdefghijklmnopqrstuvwxyz':
            yield pkg[:i] + c + pkg[i+1:], pkg[:i] + c + pkg[i:]
        

def try_install(package_name):
    try:
        result = subprocess.run(
            ["pip", "install", package_name, "--no-deps", "--no-cache-dir"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=15  # prevent hanging
        )
        success = result.returncode == 0
        output = result.stdout.decode("utf-8")
        error = result.stderr.decode("utf-8")
        return success, output, error
    except subprocess.TimeoutExpired:
        return False, "", "Timeout"
    

import requests
import json
import re # For regular expressions in URL checks

def fetch_pypi_metadata(package_name):
    """
    Fetches the JSON metadata for a given package from PyPI.
    Returns None if the package is not found or an error occurs.
    """
    url = f"https://pypi.org/pypi/{package_name}/json"
    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()  # Raise an HTTPError for bad responses (4xx or 5xx)
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error fetching metadata for '{package_name}': {e}")
        return None

def analyze_metadata_for_red_flags(package_name):
    """
    Analyzes a package's PyPI metadata for common red flags indicative of typosquatting
    or other suspicious behavior.
    """
    print(f"\n--- Analyzing '{package_name}' Metadata for Red Flags ---")

    # 1. Fetch metadata for the package
    metadata = fetch_pypi_metadata(package_name)
    if not metadata:
        print(f"Could not retrieve metadata for '{package_name}'. It might not exist or there was a network issue.")
        return {
            "package_name": package_name,
            "analysis_status": "metadata_fetch_failed",
            "red_flags": []
        }

    info = metadata.get('info', {})
    releases = metadata.get('releases', {})

    # Extract relevant info
    package_name_from_meta = info.get('name')
    summary = info.get('summary')
    description = info.get('description', '')
    author = info.get('author')
    author_email = info.get('author_email')
    home_page = info.get('home_page')
    project_urls = info.get('project_urls', {})
    license_info = info.get('license')
    classifiers = info.get('classifiers', [])
    requires_dist = info.get('requires_dist') # Dependencies
    upload_time = info.get('upload_time_iso_8601') # First upload time of the latest version

    print("\n--- Basic Package Info ---")
    print(f"Name: {package_name_from_meta}")
    print(f"Summary: {summary}")
    print(f"Author: {author} <{author_email}>")
    print(f"Homepage: {home_page}")
    print(f"Project URLs: {json.dumps(project_urls, indent=2)}")
    print(f"License: {license_info}")
    print(f"Latest Version Upload Time: {upload_time}")
    print(f"Dependencies: {requires_dist}")
    print(f"Number of releases: {len(releases)}")

    print("\n--- Heuristics: Metadata Red Flags ---")
    red_flags_found = []

    # Heuristic 1: Missing or Generic Summary/Description
    if not summary or summary.strip() == '':
        red_flags_found.append("  - Missing or empty 'summary'.")
    # Check if description is too short or just generic boilerplate
    if not description or len(description.strip()) < 50:
        red_flags_found.append("  - Very short or empty 'description'.")
    # Add check for common placeholder descriptions
    if description and any(keyword in description.lower() for keyword in ["description goes here", "add your description", "this is a test package"]):
        red_flags_found.append("  - Generic placeholder text in 'description'.")


    # Heuristic 2: Suspicious Author/Email
    if not author or not author_email:
        red_flags_found.append("  - Missing 'author' or 'author_email'.")
    elif author_email and any(domain in author_email.lower() for domain in ["@example.com", "@null.com", "@test.com", "@mail.com", "@pypi.org"]):
        red_flags_found.append(f"  - Suspicious generic/placeholder author email: {author_email}")
    elif author_email and not re.match(r"[^@]+@[^@]+\.[^@]+", author_email):
        red_flags_found.append(f"  - Malformed author email: {author_email}")

    # Heuristic 3: Missing or Suspicious URLs (Homepage/Project URLs)
    if not home_page and not project_urls:
        red_flags_found.append("  - No 'home_page' or 'project_urls' provided.")
    else:
        all_urls = []
        if home_page:
            all_urls.append(home_page)
        all_urls.extend(list(project_urls.values()))

        suspicious_domains = [
            '.xyz', '.top', '.ru', '.cn', '.gdn', '.pw', '.me', '.tk', # Common TLDs for malicious sites
            'bit.ly', 'goo.gl', 'tinyurl.com', 'is.gd', 't.co' # URL shorteners
        ]
        legit_domains = [
            'github.com', 'gitlab.com', 'readthedocs.io', 'pypi.org',
            'apache.org', 'python.org', 'djangoproject.com', 'numpy.org',
            'scipy.org', 'pytorch.org', 'tensorflow.org' # Add more as needed for popular packages
        ]

        for url in all_urls:
            if url:
                # Basic URL validity check (does not check reachability)
                if not url.startswith(('http://', 'https://')):
                    red_flags_found.append(f"  - Malformed URL (missing http/s protocol): {url}")
                # Check for suspicious domains
                if any(domain in url.lower() for domain in suspicious_domains):
                    red_flags_found.append(f"  - Suspicious domain in URL: {url}")
                # Check if URL points to common code hosting/docs (absence can be a red flag)
                if not any(domain in url.lower() for domain in legit_domains):
                    red_flags_found.append(f"  - URL not pointing to common legitimate code hosting/docs site: {url}")
                # Check for IP addresses instead of domain names (can be suspicious)
                if re.match(r"https?:\/\/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}", url):
                    red_flags_found.append(f"  - IP address used in URL instead of domain name: {url}")

    # Heuristic 4: Missing or Generic License
    if not license_info or "UNKNOWN" in license_info.upper() or len(license_info) < 5:
        red_flags_found.append("  - Missing or generic 'license' information.")
    elif license_info.lower() in ["gpl", "mit", "apache license 2.0", "bsd license"] and not ("license" in classifiers):
        # A bit more nuanced: if a common license is specified, but not in classifiers, it might be sloppy
        pass # This is not a strong red flag on its own for typosquatting

    # Heuristic 5: Few Releases/Very New Package
    # This is often the case for typosquatting attempts
    if not releases or len(releases) == 1:
        red_flags_found.append(f"  - Only {len(releases)} release(s) found. Very new or single-release packages mimicking existing ones are suspicious.")
    elif len(releases) > 0: # Check if the latest upload time is very recent
        # Get the upload time of the latest version (as per info.upload_time_iso_8601)
        # This is for the *latest* version. To truly check "newness" of the package,
        # you'd need to parse all release upload times or check first_upload_time if available.
        # For this example, we'll stick to what's easily available.
        from datetime import datetime, timedelta, timezone
        if upload_time:
            try:
                # Ensure timezone awareness for comparison
                upload_dt = datetime.fromisoformat(upload_time.replace('Z', '+00:00'))
                now_dt = datetime.now(timezone.utc)
                if now_dt - upload_dt < timedelta(days=7): # Uploaded within the last week
                    red_flags_found.append(f"  - Latest release uploaded very recently ({upload_time}). New packages mimicking existing ones are suspicious.")
            except ValueError:
                pass # Malformed date string

    # Heuristic 6: Excessive or Unusual Dependencies (requires_dist)
    # This requires domain knowledge, but some patterns can be suspicious
    if requires_dist:
        # Example: a simple utility package requiring something like 'cryptography' or 'requests' without obvious need
        suspicious_dependencies_patterns = [
            r"requests(?![a-zA-Z0-9])", # requests, but not requests-toolbelt
            r"urllib3",
            r"cryptography",
            r"pyinstaller",
            r"setuptools", # often misused in malicious setup.py
            r"sys", # not a dependency, but often used for exec calls
            r"os" # not a dependency, but often used for exec calls
        ]
        for dep_string in requires_dist:
            if any(re.search(pattern, dep_string, re.IGNORECASE) for pattern in suspicious_dependencies_patterns):
                red_flags_found.append(f"  - Potentially suspicious dependency: '{dep_string}'. Check if it's necessary for this package's stated purpose.")
    else:
        # Packages with no dependencies can also be suspicious if they mimic complex libraries
        # This is a weak flag unless combined with other strong ones
        if len(releases) > 1 and len(description.strip()) > 50 and not classifiers:
             red_flags_found.append("  - No dependencies declared for a seemingly non-trivial package. Could indicate hidden functionality.")


    print("\n--- Analysis Summary ---")
    if red_flags_found:
        print(f"'{package_name}' has detected red flags:")
        for flag in red_flags_found:
            print(flag)
    else:
        print(f"'{package_name}' does not show obvious metadata red flags.")

    return {
        "package_name": package_name,
        "analysis_status": "completed",
        "red_flags": red_flags_found
    }



if __name__ == "__main__":
    packages_to_analyze = []
    for subst, inser in mutate_package('pandas'):
        packages_to_analyze.append(subst)
        packages_to_analyze.append(inser)

    for pkg_name in packages_to_analyze:
        result = analyze_metadata_for_red_flags(pkg_name)
        print("\n" + "="*80) # Separator for readability

