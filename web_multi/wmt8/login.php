<?php 
  session_start(); 
  include("passwords.php"); 
  if (isset($_POST["ac"]) && $_POST["ac"]=="log") { 
    if (isset($USERS[$_POST["username"]]) && $USERS[$_POST["username"]]==$_POST["password"]) { 
      $_SESSION["logged"]=$_POST["username"]; 
     } else { 
      echo '<p>Wrong username or password!</p>'; 
     }; 
  }; 
  if (isset($_SESSION["logged"]) && array_key_exists($_SESSION["logged"],$USERS)) { // the user is logged
    header("Location: dbinteraction.php");
  } else {
    echo '<form action="login.php" method="post">';
    echo '  <input type="hidden" name="ac" id="ac" value="log">'; 
    echo '  Username: <input type="text" name="username" id="username"><br>'; 
    echo '  Password: <input type="password" name="password" id="password"><br>'; 
    echo '  <input type="submit" value="Login">'; 
    echo '</form>'; 
    echo '<p>Not registered yet? <a href="registration.html">Sign up now!</a></p>';
  }; 
?>