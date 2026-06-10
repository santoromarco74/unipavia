<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title>PHP + MySQL trial</title>
    </head>
    <body>
        <?php
            session_start();
            include("passwords.php");
            check_logged();
        ?>
        <h1>Interaction with a remote database</h1>
        <form name="f1" action="db.php" method="post">
            1- Show database content
            <input type="hidden" name="action" id="action" value="1">
            <input type="submit" value="Ok">
        </form>
        <form name="f2" action="db.php" method="post">
            2- Show data of the user whose name is
            <input type="hidden" name="action" id="action" value="2">
            <input type="text" name="n" id="n">
            <input type="submit" value="Ok">
        </form>
        <form name="f3" action="db.php" method="post">
            3- Enter a new record
            <input type="hidden" name="action" id="action" value="3">
            <input type="text" name="n" id="n" value="Name" size="10">
            <input type="text" name="c" id="c" value="City" size="10">
            <input type="text" name="e" id="e" value="E-mail" size="10">
            <input type="text" name="b" id="b" value="Birth year" size="10">
            <input type="submit" value="Ok">
        </form>
        <form name="f4" action="db.php" method="post">
            4- Delete the record of the user whose name is
            <input type="hidden" name="action" id="action" value="4">
            <input type="text" name="n" id="n">
            <input type="submit" value="Ok">
        </form>
    </body>
</html>