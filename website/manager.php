<?php
	function distance($lat1, $lon1, $lat2, $lon2, $unit) 
	{ 
   		$theta = $lon1 - $lon2; 
   		$dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) +  cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta)); 
   		$dist = acos($dist); 
   		$dist = rad2deg($dist); 
   		$miles = $dist * 60 * 1.1515;
   		$unit = strtoupper($unit);

   		if ($unit == "K") 
      		return ($miles * 1.609344); 
   		else 
      		return $miles;
	}


    require ('globals.inc.php');
    
    // Lookup the active Contest
	$ch = curl_init();
	$where = "where={\"active\":1}"; 
	curl_setopt($ch, CURLOPT_URL, "https://api.parse.com/1/classes/Contest?" . urlencode($where));
    curl_setopt($ch, CURLOPT_HTTPHEADER, $parseHeadersGet);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    $response = curl_exec($ch);       
    curl_close($ch);
	$temp = json_decode($response);
	$contest = $temp->results[0];
	
	echo "Monitoring " . $contest->name . "...\n";
	
	// Loop forever
	while(1) {
	
		// Remove all bots that don't have the prize
		
	
		// Get the player with the prize
	    $data = array(
	    	'contestObject' => array(
	    		'__type' => 'Pointer',
	    		'className' => 'Contest',
	    		'objectId' => $contest->objectId
	    		),
	    	'hasprize' => 1
	    	);
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, "https://api.parse.com/1/classes/Player?include=userObject&where=" . json_encode($data));
    	curl_setopt($ch, CURLOPT_HTTPHEADER, $parseHeadersGet);
    	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    	$response = curl_exec($ch);       
    	curl_close($ch);
		$players = json_decode($response);
		$playerWithPrize = $players->results[0];
		

		// Has it been more than 3 minutes since this PlayerWithPrize acquired the prize?
		//
		if(! is_null($playerWithPrize->userObject)) {
			$elapsed = time() - strtotime($playerWithPrize->acquiredprizeAt->iso);
			echo $playerWithPrize->userObject->displayname . " has held the prize for " . $elapsed . " seconds\n";
			if($elapsed < (3 * 60)) {
				sleep(5);
				continue;
			}
		}
				
		
		// If the player with the prize is out of range (> 1 mile), drop the prize



		// Determine the distance players are from the prize
		//
		
		// Get all players
	    $data = array(
	    	'contestObject' => array(
	    		'__type' => 'Pointer',
	    		'className' => 'Contest',
	    		'objectId' => $contest->objectId
	    		),
	    	'active' => 1,
	    	);
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, "https://api.parse.com/1/classes/Player?include=userObject&where=" . json_encode($data));
    	curl_setopt($ch, CURLOPT_HTTPHEADER, $parseHeadersGet);
    	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    	$response = curl_exec($ch);       
    	curl_close($ch);
		$players = json_decode($response);
		
		// How far is each player from the prize?
		echo "--------------------------------------\n";
		foreach($players->results as $player) {
			// Skip the player with the prize
			if(strcmp($player->objectId, $playerWithPrize->objectId) == 0)
				continue;
				
			$miles = distance(
				$playerWithPrize->location->latitude,
				$playerWithPrize->location->longitude,
				$player->location->latitude,
				$player->location->longitude,
				"m"
				);
			$feet = $miles * 5280;
			if($player->bot > 0)
				echo "Bot - feet: " . $feet . "\n";
			else
				echo $player->userObject->displayname . " - feet: " . $feet . "\n";
				
				
			// Check if prize can be acquired
			//
			// 1. Player is within 100 ft of PlayerWithPrize
			// 2. Player cannot be a "bot"
			//
			if(feet <= 100.0) {
			
				// Is the player a bot?
				if($player->bot > 0)
					continue;
				
				// The playerWithPrize loses the prize
			    $data = array(
    				'hasprize' => 0,
			    	);
			    $ch = curl_init();
				curl_setopt($ch, CURLOPT_URL, "https://api.parse.com/1/classes/Player/" . $playerWithPrize->objectId);
			    curl_setopt($ch, CURLOPT_HTTPHEADER, $parseHeadersPut);
			    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
			    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
			    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
			    $updateresponse = curl_exec($ch);       
			    curl_close($ch);
			    
				// This player acquires the prize
				$isoDate = gmdate('Y-m-d\TH:i:s.000\Z');
			    $data = array(
    				'hasprize' => 1,
			    	'acquiredprizeAt' => array(
			    		'__type' => "Date",
			    		'iso' => $isoDate
			    		),
			    	);
			    $ch = curl_init();
				curl_setopt($ch, CURLOPT_URL, "https://api.parse.com/1/classes/Player/" . $player->objectId);
			    curl_setopt($ch, CURLOPT_HTTPHEADER, $parseHeadersPut);
			    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
			    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
			    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
			    $updateresponse = curl_exec($ch);       
			    curl_close($ch);
				
				// Send a Notification to the Winner
				$channel = "server_" . $player->userObject->objectId;
				$winnername = "Bot";
				if(is_null($player->userObject)) {
					$message = "You have just acquired the prize!  It was dropped by another player.  You have 3 minutes to get away.";
				}
				else {
					$winnername = $player->userObject->displayname;
					$message = "You have just acquired the prize from " . $playerWithPrize->userObject->displayname . ". You have 3 minutes to get away";
				}
				$data = array('channels' => array($channel), 'data' => array('alert' => $message));
				$ch = curl_init();
				curl_setopt($ch, CURLOPT_URL, "https://api.parse.com/1/push");
			    curl_setopt($ch, CURLOPT_HTTPHEADER, $parseHeadersPut);
			    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
			    curl_setopt($ch, CURLOPT_POST, 1);
			    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
			    $notifresponse = curl_exec($ch);
			    curl_close($ch);

				// Send a Notification to the Loser
				$losername = "Bot";
				if($playerWithPrize->bot == 0) {
					$channel = "server_" . $playerWithPrize->userObject->objectId;
					$losername = $playerWithPrize->userObject->displayname;
					$message = "You have just lost the prize to " . $player->userObject->displayname;
					$data = array('channels' => array($channel), 'data' => array('alert' => $message));
					$ch = curl_init();
					curl_setopt($ch, CURLOPT_URL, "https://api.parse.com/1/push");
				    curl_setopt($ch, CURLOPT_HTTPHEADER, $parseHeadersPut);
				    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
			    	curl_setopt($ch, CURLOPT_POST, 1);
				    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
				    $notifresponse = curl_exec($ch);       
				    curl_close($ch);
				}

				echo $winnername . " has taken the prize from " . $losername . "\n";
			    
				// Get out of this loop
				break;
			}
		}
		
		sleep(5);
	}
?>
