$AZRG3 = "The_Taco_King_3"
$AZRG4 = "The_Taco_King_4"
$tags =@{"Type"="VMs"}
$Template = "https://raw.githubusercontent.com/benjaminsmorgan/Azrue-ARM/main/Win16template.json"
$Param3 = "https://raw.githubusercontent.com/benjaminsmorgan/Azrue-ARM/main/TC-PM-01.parameters.json"
$Param4 = "https://raw.githubusercontent.com/benjaminsmorgan/Azrue-ARM/main/TC-PM-02.parameters.json"
New-AzResourceGroup -Name $AZRG3 -Location 'eastus' -Tag $tags 
New-AzResourceGroup -Name $AZRG4 -Location 'eastus' -Tag $tags
New-AzResourceGroupDeployment -ResourceGroupName $AZRG3 -TemplateUri $Template -TemplateParameterUri $Param3
New-AzResourceGroupDeployment -ResourceGroupName $AZRG3 -TemplateUri $Template -TemplateParameterUri $Param4