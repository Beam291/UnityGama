# Unity VR GAMA

<div style="text-align: justify"> 
Unity VR GAMA project is the project focuses on the coupling between VR and computer simulation and was applied to the CityScope Bac Hung Hai model. This model, which is based on an agent-based model developed with the GAMA platform, allows to simulate the Bac Hung Hai irrigation system and studies several issues including increasing demand, pollution, under-investment, depletion of resources, or environmental change.
</div>

## Requirement Installed
Because each different version of GAMA, there is a lot of changes so you have to use specific version for the project. There is no demand on which version have to use for the project.

- Unity ([Unity download](https://unity.com/download)).
- GAMA v1.8.1 (Eclipse version - [Github Gama](https://github.com/gama-platform/gama.git)).
- Eclipse (Prefer to use 2022-03 version - [Eclipse download](https://www.eclipse.org/downloads/packages/release/2022-03/r/eclipse-ide-java-and-dsl-developers)).

## Tutorial
### Unity
- Install the Unity 
- Add the existed project in the BHHVR_UNITY folder (If you lastest version of Unity, you don't need to worry just follow the instruction of the warning popup from Unity).
- Load the Unity project.
- Every components of the project still not load 100% since it new computer. To load it, in Unity, open the Asset/Scences/BHHVR.

### GAMA + Eclipse
The project is no really working well with the stable release so you have to install the git version. To do that please follow the instruction on website ([GAMA GIT install guide](https://gama-platform.org/wiki/InstallingGitVersion)).
After install follow the instruction, load the project from BHHVR_GAMA folder.

## How the program work
To run the program. You have to run the Unity and the GAMA at the same time. 
- At the Unity side, you need to press **F** so the Unity will load all the data from GAMA (GAMA side have to lauch before that so this step can work).
- Each time you weant to change any node, select it and press **Space** to send the order to GAMA and at the GAMA side it will change.

Because the project still under devlopment and still not finish so it can't not automatically load the data from GAMA side. You have to to it manually by press **F** again. And when you change from GAMA side, to load it to Unity, you have to press **F** in the Unity to load the new data.

Moreover, at the Unity side, you also have a table at the left side to change the different type of node. 

*Note:* Because the project still under development and the VR feature still not add in due to the optimize of the project not working well and will crash the computer so you cannot use VR at the momment.