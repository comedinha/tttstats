<?php
/*------------------------\
|        TTT STATS        |
|	   Beta           |
|=========================|
|� 2013 SNGaming.org      |
|   All Rights Reserved   |
|=========================|
|   Website printout      |
|      beta testing       |
|      by Handy_man       |
\------------------------*/
include("./includes/header.php");
include("./includes/config.php");	

?>

<p class="center">
<strong>Add a new Admin</strong><br/>
</p>

<form action='add-admin-process.php' method='post' onsubmit='return checkEmail(this);'>
<span class="formData">Admin Login</span>
<input name="nick" type="text" id="nick" placeholder="Example: Handy_man">
<br/>
<span class="formData">Admin SteamID</span>
<input name="steamID" type="text" id="steamID" placeholder="STEAM_0:">
<br/>
<span class="formData">Admin E-mail</span>
<input name="e-mail" type="text" id="e-mail" placeholder="admin@gmail.com">
<br/>
<span class="formData">Admin Password</span>
<input name="password" type="text" id="password" placeholder="Password">
<br/>
<span class="formData">Repeat Password</span>
<input name="password2" type="text" id="password2" placeholder="Repeat password">
<br/>

<p class="center">
<button class='button' type='submit'>Add new Admin</button>

</form>
</p>

<?PHP
include("./includes/footer.php");
?>
