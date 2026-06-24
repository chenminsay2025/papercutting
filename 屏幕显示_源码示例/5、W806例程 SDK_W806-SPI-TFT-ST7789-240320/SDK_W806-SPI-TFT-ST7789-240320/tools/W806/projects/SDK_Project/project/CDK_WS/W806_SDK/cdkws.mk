.PHONY: clean All Project_Title Project_Build Project_PostBuild

All: Project_Title Project_Build Project_PostBuild

Project_Title:
	@echo "----------Building project:[ W806_SDK - BuildSet ]----------"

Project_Build:
	@make -r -f W806_SDK.mk -j 4 -C  ./ 

Project_PostBuild:
	@echo Executing Post Build commands ...
	@export CDKPath="C:/Users/Jerry@WLK/AppData/Roaming/C-Sky/CDK" CDK_VERSION="V2.10.1" ProjectPath="C:/W806 SDK/SDK_W806-SPI-TFT-ST7789-240320/tools/W806/projects/SDK_Project/project/CDK_WS/W806_SDK/" && ../../../../../../../tools/W806/utilities/cdk_aft_build.sh;../../../../../../../tools/W806/utilities/aft_build_project.sh 
	@echo Done


clean:
	@echo "----------Cleaning project:[ W806_SDK - BuildSet ]----------"

