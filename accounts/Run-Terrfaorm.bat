echo off

Rem ************************************************************
Rem Run-Terraform.bat
echo Run-Terraform.bat %1
echo   
Rem ************************************************************



echo ************************************************************
echo  %1 for sharedservice account
echo ************************************************************

cd c3s_sharedservice
terraform %1
cd..

echo ************************************************************
echo  %1 for application account
echo ************************************************************
cd c3s_application
terraform %1
cd..

echo ************************************************************
echo  %1 for pen-test-platform account
echo ************************************************************
cd c3s_pentestplatform
terraform %1
cd..