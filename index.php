<?php
$file = 'notes.txt';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['note'])) {
    $note = trim($_POST['note']);
    if ($note !== '') {
        $entry = "[" . date("Y-m-d H:i:s") . "] " . htmlspecialchars($note) . "\n";
        file_put_contents($file, $entry, FILE_APPEND | LOCK_EX);
    }
    header("Location: index.php");
    exit;
}

$notes = file_exists($file) ? file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) : [];
?>
<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.0//EN" "http://www.wapforum.org/DTD/xhtml-mobile10.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>WAP Notes</title>
</head>
<body bgcolor="#ffffff" text="#000000">
    <h3>WAP Note App</h3>
    
    <form method="post" action="index.php">
        <p>
            <label for="note"><b>Likh Kar Save Karein:</b></label><br />
            <textarea id="note" name="note" rows="3" cols="20"></textarea>
        </p>
        <p>
            <input type="submit" value="Save Note" />
        </p>
    </form>
    
    <hr />
    
    <h4>Saved Notes:</h4>
    <?php if (empty($notes)): ?>
        <p>Koi note nahi hai.</p>
    <?php else: ?>
        <ul>
            <?php foreach (array_reverse($notes) as $item): ?>
                <li><?php echo $item; ?></li>
            <?php endforeach; ?>
        </ul>
    <?php endif; ?>
</body>
</html>
