<?php
// Configurazione parametri Database
$host     = "localhost";
$user     = "root";
$password = ""; // Lascia vuoto se usi la configurazione standard di XAMPP/MAMP
$dbname   = "algora_db";

// Connessione al Database
$conn = new mysqli($host, $user, $password, $dbname);

if ($conn->connect_error) {
    die("Connessione fallita: " . $conn->connect_error);
}

// Inizializzazione variabili
$successo = false;
$errore = "";

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    // Sanitizzazione input
    $nome      = trim(htmlspecialchars($_POST['nome'] ?? ''));
    $ente      = trim(htmlspecialchars($_POST['ente'] ?? ''));
    $email     = filter_var(trim($_POST['email'] ?? ''), FILTER_VALIDATE_EMAIL);
    $tipo      = trim(htmlspecialchars($_POST['tipo'] ?? ''));
    $messaggio = trim(htmlspecialchars($_POST['messaggio'] ?? ''));

    // Validazione base
    if (!$nome || !$email || !$messaggio) {
        $errore = "Per favore compila tutti i campi obbligatori (Nome, Email, Messaggio).";
    } else {
        // Query preparata per prevenire SQL Injection
        $stmt = $conn->prepare("INSERT INTO contatti (nome, ente, email, tipo, messaggio) VALUES (?, ?, ?, ?, ?)");
        $stmt->bind_param("sssss", $nome, $ente, $email, $tipo, $messaggio);

        if ($stmt->execute()) {
            $successo = true;
        } else {
            $errore = "Errore durante il salvataggio dei dati: " . $stmt->error;
        }
        $stmt->close();
    }
}
$conn->close();
?>
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Esito Invio — Algora Studio</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<nav id="nav">
  <a href="index.html" class="nav-logo">
    <span class="brand">ALGORA</span>
    <span class="sub">STUDIO</span>
  </a>
</nav>

<section style="padding-top: 140px; min-height: 80vh;">
  <div style="max-width: 600px; margin: 0 auto; background: var(--parchment-2); padding: 40px; border: 1px solid var(--border);">
    <?php if ($successo): ?>
        <p class="label" style="color: var(--green);">Messaggio Ricevuto</p>
        <h2 style="margin-top: 10px;">Grazie, <?= htmlspecialchars($nome) ?>!</h2>
        <p style="margin-top: 15px; color: var(--mid);">La tua richiesta per l'ente <strong><?= htmlspecialchars($ente ?: 'Non specificato') ?></strong> è stata salvata con successo nel nostro sistema.</p>
        <p style="margin-top: 10px; color: var(--mid);">Ti risponderemo all'indirizzo <em><?= htmlspecialchars($email) ?></em> entro 24 ore lavorative.</p>
        <a href="index.html" class="btn btn-dark" style="margin-top: 25px;">Torna alla Home</a>
    <?php else: ?>
        <p class="label" style="color: #a00;">Errore</p>
        <h2 style="margin-top: 10px;">Si è verificato un problema</h2>
        <p style="margin-top: 15px; color: var(--mid);"><?= htmlspecialchars($errore) ?></p>
        <a href="contatti.html" class="btn btn-outline" style="margin-top: 25px;">Torna al modulo</a>
    <?php endif; ?>
  </div>
</section>

</body>
</html>