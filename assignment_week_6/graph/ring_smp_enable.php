<?php
	
	$filename = $argv[1];
	$limit = $argv[2];
	
	if(!isset($filename)) {
		$filename = 'ring_smp_enable';
		$limit = '5000';
	}
	
	$data = explode("\n",file_get_contents("../source/{$filename}.txt"));
	
	foreach ($data as $key => $value) {
		$v = explode(" ", trim($value));
		if($v[0] == $limit) {
			echo implode(" ", $v) . "\n";
		}
	}	
	
?>