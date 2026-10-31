<?php
$file = 'notes.txt';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['n'])) {
    $note = trim($_POST['n']);
    if ($note !== '') {
        $entry = htmlspecialchars($note) . "\n";
        file_put_contents($file, $entry, FILE_APPEND | LOCK_EX);
    }
    header("Location: index.php");
    exit;
}

$notes = file_exists($file) ? file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) : [];
?>
<html>
<head>
<title>Note</title>
</head>
<body>
<h3>Notes</h3>
<form action="index.php" method="post">
Text:<br>
<input type="text" name="n"><br>
<input type="submit" value="Save">
</form>
<hr>
<?php
if (!empty($notes)) {
    foreach (array_reverse($notes) as $item) {
        echo "<p>- " . $item . "</p>";
    }
}
?>
</body>
</html>
