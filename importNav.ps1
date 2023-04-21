# Copyright Ivan Ling 2023

# import module for Nav Administrative CmdLets
Import-Module "C:\Program Files\Microsoft Dynamics 365 Business Central\180\Service\NavAdminTool.ps1"

$srcStoreScope = "LocalMachine"
$srcStoreName = "WebHosting"
$dstStoreScope = "LocalMachine"
$dstStoreName = "My"
$toCopyOrNotToCopy = null
$subject = '*nav.pbagroup.net*'

$srcStore = New-Object System.Security.Cryptography.X509Certificates.X509Store $srcStoreName, $srcStoreScope
$srcStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)

$ThumbPrint = (Get-Childitem cert:\LocalMachine\WebHosting\ | Where-Object { $_.subject -like  $subject }| Sort-Object -Property NotAfter -Descending | Select-Object -first 1).Thumbprint
$ThumbPrintMy = (Get-Childitem cert:\LocalMachine\My\ | Where-Object { $_.subject -like $subject }| Sort-Object -Property NotAfter -Descending | Select-Object -first 1).Thumbprint

# ssl exists in both Web Hosting and Personal/My certificate stores
if (($ThumbPrint -ne $null) -and ($ThumbPrintMy -ne $null))
{
	# copy if cert is different
	if ($ThumbPrint -ne $ThumbPrintMy)
	{
		# copy when
		$toCopyOrNotToCopy = "ThatIsTheQuestion"
	}
}
else if (($ThumbPrint -ne $null) -and ($ThumbPrintMy -eq $null))
{
	# copy when ssl cert exists in Web Hosting but not in Personal/My
	$toCopyOrNotToCopy = "ThatIsTheQuestion"
}

if ($toCopyOrNotToCopy -ne null)
{
	# copy from Web Hosting to Personal/My
	$cert = $srcStore.certificates | Where-Object { $_.subject -like $subject }| Sort-Object -Property NotAfter -Descending | Select-Object -first 1
	$dstStore = New-Object System.Security.Cryptography.X509Certificates.X509Store $dstStoreName, $dstStoreScope
	$dstStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
	$dstStore.Add($cert[0])
	$dstStore.Close

	# restart nav/bc instances	
	Set-NAVServerConfiguration BC180-AU_PBA-SG -KeyName ServicesCertificateThumbprint -KeyValue $ThumbPrint
	Restart-Navserverinstance BC180-AU_PBA-SG

	Set-NAVServerConfiguration BC180-AU_PBA-SG_UAT -KeyName ServicesCertificateThumbprint -KeyValue $ThumbPrint
	Restart-Navserverinstance BC180-AU_PBA-SG_UAT
}
$srcStore.Close

