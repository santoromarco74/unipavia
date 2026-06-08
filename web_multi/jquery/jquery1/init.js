function mytext() {
    $("#t1").delay(0).fadeIn(300);
    $("#t1").delay(1400).fadeOut(300);
    $("#t2").delay(2100).fadeIn(300);
    $("#t2").delay(1400).fadeOut(300);
    $("#t3").delay(5200).fadeIn(300);
    $("#t3").delay(1400).fadeOut(300);
    $("#t4").delay(7300).fadeIn(300);
    $("#t5").delay(8500).fadeIn(200);
    $("#replaylink").delay(9000).fadeIn(2000);
}
function setCookie(key, value) {
    var expires = new Date();
    var minutes = 1;
    expires.setTime(expires.getTime() + (minutes * 60 * 1000));
    document.cookie = key + '=' + value + '; expires=' +
    expires.toUTCString();
}
function getCookie(key) {
    var keyValue = document.cookie.match('(^|;) ?' + key +
    '=([^;]*)(;|$)');
    return keyValue ? keyValue[2] : null;
}
function replay() {
    setCookie('fc', '0');
    setTimeout(function(){this.location.reload()}, 300);
}
function showStaticText() {
    $("#mainvideo").css("border", "0px");
    $("#mainvideo video").hide();
    $("#t4").show();
    $("#t5").show();
    $("#replaylink").show();
}
$(document).ready(function() {
    if (getCookie('fc') != '1') {
        $("#mainvideo video").bind('ended', function() {
            mytext();
            $("#mainvideo").fadeOut(4000, function() {
            $("#mainvideo video").remove();
            });
        });
    setCookie('fc', '1');
    } else {
    showStaticText();
    }
});