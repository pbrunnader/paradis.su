<?php
	
	$filename1 = $argv[1];
	$filename2 = $argv[2];
	
	$match = $argv[3]-1;
	$column = $argv[4]-1;
	$limit = $argv[5];
	
	$list = array();
	
	$data = explode("\n",file_get_contents("../source/{$filename1}.txt"));
	
	foreach ($data as $key => $value) {
		$v = explode(" ", trim($value));
		if($v[$column] == $limit) {
			$list[$v[$match]][0] = $v;
		}
	}	


	$data = explode("\n",file_get_contents("../source/{$filename2}.txt"));
	
	foreach ($data as $key => $value) {
		$v = explode(" ", trim($value));
		if($v[$column] == $limit) {
			$list[$v[$match]][1] = $v;
		}
	}	
	
	foreach ($list as $key => $value) {
		echo implode(" ", $value[0]) . " " . implode(" ", $value[1]) . " " . ($value[1][2]/$value[0][2]) . "\n";
	}

	
?>