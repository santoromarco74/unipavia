<!DOCTYPE html>
<html>
  <head>
    <title>Registration result</title>
    <meta charset="utf-8">    
  </head>
  <body>
    <?php 
      $con = mysqli_connect("localhost", "root", ""); 
      if (!$con) {
        die("Connection error: " . mysqli_error($con));
      }

      $exists = false; 
      mysqli_select_db($con, "mydb");

      $result = mysqli_query($con, "SELECT username FROM usrpwd");
      while($row = mysqli_fetch_assoc($result)){
        if ( $row['username'] == $_POST["usrn"]) {
          echo 'Username already exists; <a href="registration.html">back 
                to registration page</a>';
          $exists = true;
          break;
        }
      }

      if (! $exists) {
        $sql = "INSERT INTO usrpwd (username, password) VALUES ('" . 
               $_POST["usrn"] . "', '" . $_POST["pass"] . "')";
        $result = mysqli_query($con, $sql);
        echo '<p>Registration successful!</p>';
        echo '<a href="dbinteraction.php">Login to enter the website</a>';
      }
    ?>
  </body>
</html>
