$AZRG3 = "The_Taco_King_3"
$AZRG4 = "The_Taco_King_4"
$tags =@{"Type"="VMs"}
$Template = "C:\Users\Benja\source\repos\Azrue-ARM\Win16template.json"
$Param3 = "C:\Users\Benja\source\repos\Azrue-ARM\TC-PM-01.parameters.json"
$Param4 = "C:\Users\Benja\source\repos\Azrue-ARM\TC-PM-02.parameters.json"
New-AzResourceGroup -Name $AZRG3 -Location 'eastus' -Tag $tags 
New-AzResourceGroup -Name $AZRG4 -Location 'eastus' -Tag $tags
New-AzResourceGroupDeployment -ResourceGroupName $AZRG3 -TemplateFile $Template -TemplateParameterFile $Param3
New-AzResourceGroupDeployment -ResourceGroupName $AZRG3 -TemplateFile $Template -TemplateParameterFile $Param4