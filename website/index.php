<?php
    $securepage = true;
    require ('globals.inc.php');
?>
<HTML>
    <HEAD>
        <LINK href=/joios.css rel="STYLESHEET"></LINK>
    </HEAD>
    <BODY leftMargin="0" topMargin="0" onload="" marginwidth="0" marginheight="0">
    <table width="1000" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <?php include ('toppane.php'); ?>
                <table cellSpacing="0" cellPadding="0" border="0">
                    <tr>
                        <?php include ('leftpane.php'); ?>
                    </tr>
                </table>
                <?php include ('bottompane.php'); ?>
            </td>
        <tr>
    </table>
    </BODY>
</HTML>
