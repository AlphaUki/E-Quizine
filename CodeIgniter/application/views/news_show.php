<h1><?php echo $title; ?></h1>
<br />

<?php
	if (isset($news)) {
		echo $news->new_id;
		echo " -- ";
		echo $news->new_title;
		echo " -- ";
		echo $news->new_content;
	} else {
		echo "<br />";
		echo "Pas d'actualité !";
	}
?>