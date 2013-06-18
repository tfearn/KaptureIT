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
	
	function getFirstName($fullname) 
	{
		$arr = explode(' ',trim($fullname));
		return $arr[0];
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
	
		// Get all players
		//
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
		
		
		// Remove all bots that don't have the prize
		//
		foreach($players->results as $player) {			
			if($player->bot == 1 && $player->hasprize == 0) {
				$data = array();
				$ch = curl_init();
				curl_setopt($ch, CURLOPT_URL, "https://api.parse.com/1/classes/Player/" . $player->objectId);
				curl_setopt($ch, CURLOPT_HTTPHEADER, $parseHeadersPut);
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
				curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE");
				curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
				$deleteresponse = curl_exec($ch);       
				curl_close($ch);
			}
		}
		
	
		
		// Has the contest ended?
		//
		$contestTimeLeft = strtotime($contest->endtime->iso) - time();
		if($contestTimeLeft <= 0.0) {

			foreach($players->results as $player) {
			
				// Does a human player have the prize?
				$humanWinner = 0;
				if($player->hasprize == 1 && ! is_null($player->userObject)) {
					$humanWinner = 1;
					
					// Send a notification to all contest players about the winner
					$channel = "contest_" . $contest->objectId;
					$message = getFirstName($player->userObject->displayname) . "has won the " . $contest->name;
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
			}

			if($humanWinner == 1) {			
				// The contest is over, break out
				break;
			}
		}


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
		$playersFind = json_decode($response);
		$playerWithPrize = $playersFind->results[0];
		

		// If the player that has the prize is inactive, give the prize to a bot at that player's last location
		//
		if($playerWithPrize->active == 0) {
		
			// Take the prize away from the player
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
			
			// Create a bot with the prize.  
			$acquiredDate = gmdate('Y-m-d\TH:i:s.000\Z', time() - (24*60*60));
			$data = array(
    			'active' => 1,
    			'bot' => 1,
    			'hasprize' => 1,
    			'contestObject' => array(
					'__type' => 'Pointer',
				  	'className' => 'Contest',
				  	'objectId' => $playerWithPrize->contestObject->objectId
				  	),
			    'acquiredprizeAt' => array(
			    	'__type' => "Date",
			    	'iso' => $acquiredDate
			    	),
			    'location' => array(
			    	'__type' => "GeoPoint",
			    	'longitude' => $playerWithPrize->location->longitude,
			    	'latitude' => $playerWithPrize->location->latitude
			    	),
			    );
			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, "https://api.parse.com/1/classes/Player");
			curl_setopt($ch, CURLOPT_HTTPHEADER, $parseHeadersPut);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
			curl_setopt($ch, CURLOPT_POST, 1);
			curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
			$insertresponse = curl_exec($ch);       
			curl_close($ch);
		}
		

		// Has it been more than X seconds since this PlayerWithPrize acquired the prize?
		//
		if(! is_null($playerWithPrize->userObject)) {
			$elapsed = time() - strtotime($playerWithPrize->acquiredprizeAt->iso);
			echo $playerWithPrize->userObject->displayname . " has held the prize for " . $elapsed . " seconds\n";
			if($elapsed < $contest->shieldtime) {
				sleep(5);
				continue;
			}
			else {

				// Remove the shield from the PlayerWithPrize
				$data = array(
    				'shielded' => 0
				    );
				$ch = curl_init();
				curl_setopt($ch, CURLOPT_URL, "https://api.parse.com/1/classes/Player/" . $playerWithPrize->objectId);
				curl_setopt($ch, CURLOPT_HTTPHEADER, $parseHeadersPut);
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
				curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
				curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
				$updateresponse = curl_exec($ch);       
				curl_close($ch);
				
				// Sleep for 5 seconds and fall through
				sleep(5);
			}
		}
				
		
		// If the player with the prize is out of range (> 1 mile), drop the prize



		// How far is each player from the prize?
		echo "--------------------------------------\n";
		$playerToAcquire = NULL;
		$playerToAcquireFeet = 100000;
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

			// Is the player a bot?
			if($player->bot > 0)
				continue;
				

			// Is player is within X ft of PlayerWithPrize
			//
			if($feet <= $contest->acquirerange) {
					
				if($feet < $playerToAcquireFeet) {
					$playerToAcquire = $player;
					$playerToAcquireFeet = $feet;
				}
			}
		}
		

		// Is there a PlayerToAcquire?
		//
		if(! is_null($playerToAcquire)) {
			
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
    			'shielded' => 1,
			    'acquiredprizeAt' => array(
			    	'__type' => "Date",
			    	'iso' => $isoDate
			    	),
			    );
			$ch = curl_init();
			curl_setopt($ch, CURLOPT_URL, "https://api.parse.com/1/classes/Player/" . $playerToAcquire->objectId);
			curl_setopt($ch, CURLOPT_HTTPHEADER, $parseHeadersPut);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
			curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
			curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
			$updateresponse = curl_exec($ch);       
			curl_close($ch);
				
			// Send a Notification to the Winner
			$channel = "server_" . $playerToAcquire->userObject->objectId;
			$winnername = "Bot";
			if(is_null($playerWithPrize->userObject)) {
				$message = "You have just acquired the prize!  It was dropped by another player.  You have a limited amount of time to get away.";
			}
			else {
				$winnername = $playerToAcquire->userObject->displayname;
				$message = "You have just acquired the prize from " . getFirstName($playerWithPrize->userObject->displayname) . ". You have a limited amount of time to get away";
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
				$message = "You have just lost the prize to " . getFirstName($playerToAcquire->userObject->displayname);
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
		}
		
		sleep(5);
	}
?>
