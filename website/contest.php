<?php
    $securepage = true;
    require ('globals.inc.php');
    
    $tablewidth = 800;
    
    // Lookup the Contest
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, "https://api.parse.com/1/classes/Contest/" . $_REQUEST['id']);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $parseHeadersGet);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    $response = curl_exec($ch);       
    curl_close($ch);
	$contest = json_decode($response);
?>
<HTML>
    <HEAD>
        <LINK href=/kaptureit.css rel="STYLESHEET"></LINK>
    </HEAD>
    <BODY leftMargin="0" topMargin="0" onload="" marginwidth="0" marginheight="0">
    <table width="1000" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <?php include ('toppane.php'); ?>
                <table cellSpacing="0" cellPadding="0" border="0">
                    <tr>
                        <?php include ('leftpane.php'); ?>
                        <td vAlign="top" width="25"><IMG src="./images/spacer.gif" border="0"></td>
                        <td vAlign="top" width="95%">
                            <table border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td vAlign="top">
                                        <table id="headingTable" border="0">
                                            <tr>
                                                <td><img src="./images/spacer.gif" width="5" height="15"></td>
                                            </tr>
                                        </table>
                                        <table cellSpacing="2" cellPadding="2" width="<?php echo $tablewidth?>" border="0">
                                            <tr>
                                                <td><h1>Contest</h2></td>
                                            </tr>
                                            <tr>
                                                <td><img src="./images/spacer.gif" width="1" height="4" /></td>
                                            </tr>
                                        </table>
                                        <table cellSpacing="2" cellPadding="3" border="0" width="500">
                                            <tr>
                                                <td nowrap align="left">Name:</td>
                                                <td><?php echo $contest->name?></td>
                                            </tr>
                                            <tr>
                                                <td nowrap align="left">SubTitle:</td>
                                                <td><?php echo $contest->subtitle?></td>
                                            </tr>
                                            <tr>
                                                <td nowrap align="left">Start Time:</td>
                                                <td><?php echo date('Y-M-d h:ia T', strtotime($contest->starttime->iso))?></td>
                                            </tr>
                                            <tr>
                                                <td nowrap align="left">End Time:</td>
                                                <td><?php echo date('Y-M-d h:ia T', strtotime($contest->endtime->iso))?></td>
                                            </tr>
                                            <tr>
                                                <td nowrap align="left">Active:</td>
                                                <td><?php echo $contest->active?></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                            <br />
                            <br />
                        </td>
                    </tr>
                </table>
                <?php include ('bottompane.php'); ?>
            </td>
        </tr>
    </table>
    </BODY>
</HTML>