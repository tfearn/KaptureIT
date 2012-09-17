<?php
    $securepage = true;
    require ('globals.inc.php');
    
    $tablewidth = 800;
    
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, "https://api.parse.com/1/classes/Contest?order=-starttime");
    curl_setopt($ch, CURLOPT_HTTPHEADER, $parseHeadersGet);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    $response = curl_exec($ch);       
    curl_close($ch);
	$contests = json_decode($response);
	
	//echo $response;
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
                                                <td><img src="./images/spacer.gif" width="1" height="15"></td>
                                            </tr>
                                        </table>
                                        <table border="0">
                                            <tr>
                                                <td><h1>Contests</h2></td>
                                            </tr>
                                        </table>
                                        <TABLE cellSpacing="1" cellPadding="3" width="<?php echo $tablewidth?>" border="0">
                                            <TR>
                                                <TD class="columnheader" noWrap align="left"><b>Name</b></TD>
                                                <TD class="columnheader" noWrap align="left"><b>Start Date</b></TD>
                                                <TD class="columnheader" noWrap align="left"><b>End Date</b></TD>
                                                <TD class="columnheader" noWrap align="left"><b>Active</b></TD>
                                            </TR>
                                            <tr>
                                                <td colspan=20><img src="./images/dot.jpg" width="<?php echo $tablewidth?>" height="1"></td>
                                            </tr>
                                        <?php
											foreach($contests->results as $contest) {
                                        ?>
                                            <TR>
                                                <TD noWrap align="left"><a href="./contest.php?id=<?php echo $contest->objectId?>"><?php echo $contest->name?></a></TD>
                                                <TD noWrap align="left"><?php echo date('Y-M-d h:ia T', strtotime($contest->starttime->iso))?></TD>
                                                <TD noWrap align="left"><?php echo date('Y-M-d h:ia T', strtotime($contest->endtime->iso))?></TD>
                                                <TD noWrap align="left"><?php echo $contest->active?></TD>
                                            </TR>
                                        <?php
                                        	}
                                        ?>
                                        </TABLE>
                                        </form>
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