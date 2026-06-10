<?php
  $con = mysqli_connect("localhost", "root", ""); 
  if (!$con) {
    die("Connection error: " . mysqli_error($con));
  }
  mysqli_select_db($con,"mydb") or die(mysqli_error());

  echo "<h2>Database interaction result</h2>";
  
  if ($_POST["action"] == 1) {
    // Displays all records
    $result = mysqli_query($con,"SELECT * FROM users"); 
    while($row = mysqli_fetch_assoc($result)){
      echo "ID: " . $row['id'] . ", Name: " . $row['name'] . 
           ", City: " . $row['city'] . ", Birth year: " . 
           $row['birth_year'] . "<br>";
    }
  } elseif ($_POST["action"] == 2) { 
    // Displays the record corresponding to a specific name
    $result = mysqli_query($con,"SELECT * FROM users WHERE name = " . 
                          "'" . $_POST['n'] . "'");
    $row = mysqli_fetch_assoc($result);
    echo "ID: " . $row['id'] . ", Name: " . $row['name'] . 
         ", City: " . $row['city'] . ", Birth year: " . 
         $row['birth_year'] . "<br>";
  } elseif ($_POST["action"] == 3) { 
    // Adds a new record
    $sql = "INSERT INTO users (name,city,email,birth_year) 
            VALUES ('" . $_POST["n"] . "','" . $_POST["c"] . 
            "','" . $_POST["e"] . "','" . $_POST["b"] . "')";
    $result = mysqli_query($con,$sql);
    echo "Record added";
  } else {
    // Deletes the record corresponding to a specific name
    $sql = "DELETE FROM users WHERE name='" . $_POST["n"] . "'";
    $result = mysqli_query($con,$sql);
    echo "Record deleted";
  }
  echo '<br><br>Back to <a href="dbinteraction.php">Home page</a>';
?>