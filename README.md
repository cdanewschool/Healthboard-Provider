HealthBoard - Provider Portal
=============================

Description
-----------
Funded through the Telemedicine and Advanced Technology Research Center (TATRC) and driven by consultations with the Walter Reed National Military Medical Center (WRNMMC), HealthBoard is a visual dashboard prototype that is designed to improve better patient care through better design. Consisting of two portals—the **Patient Portal** and the **Provider Portal**—HealthBoard is designed to serve both communities through better information.

This repository includes the source for the Provider Portal. The Patient Portal is available [here](https://github.com/piim/Healthboard-Patient). Note that both portals make use of a [shared library](https://github.com/piim/Healthboard-Lib).

Installation Instructions
------------
### Configuration
1. First, check out and configure the [shared library](https://github.com/piim/Healthboard-Lib)
2. Clone the repo into your workspace by executing `git clone https://github.com/piim/Healthboard-Provider.git`
3. In Eclipse/Flex Builder choose `New > Flex Project`
4. Name the project `Healthboard-Provider` and browse to the repo under Project Location
5. Click Next twice
6. Click the `Source Path` tab and click add folder
7. Browse to `src` directory of the shared library, click open then ok
8. Go to the `Library Path` tab and make sure libs/agslib-3.0-2012-06-06.swc is included; click `Add SWC` to add it if it is not
9. Run an initial build of the project 

### Building
1. Open build.xml and make sure FLEX_HOME points to a valid sdk directory
2. Drag build/build.xml to the Ant view
3. Run the `buildLocalRelease` task (if you're going to be accessing the build over the network (i.e. localhost), run `buildNetworkRelease`)
4. Choose "Run > Run" to launch the project (login with username `piim` and password `password`, or any of the credentials in [providers.xml](https://github.com/piim/Healthboard-Lib/blob/master/src/data/providers.xml))

More Information
----------------
The prototype and designs are developed to allow patients (in this case active duty military personnel) the ability to interact with their own personal health information and electronic medical records, and healthcare providers with better access to patients and their decisions. By integrating information design principles HealthBoard provides users with enhanced and streamlined access to information, making it less intimidating and easier to understand the impacts of decisions on health outcomes.

HealthBoard is an Open Source product, designed to enhance and/or complement other existing EMR systems. HealthBoard can be used by EMR developers either completely or in a modular fashion as an enhanced presentation layer (it is currently not connected to any back-end system; all the data displayed is static data read from static XML files). Guidance documents will be included, thereby assisting in the adoption of good design principles by developers easier.

Licensing
---------
HealthBoard was developed by the Parsons Institute for Information Mapping (PIIM) funded through the Telemedicine & Advanced Technology Research Center (TATRC). Its source code is in the Public Domain. OSEHRA is hosting the project and has adopted the Apache 2.0 License for contributions made by community members.

You will find the text of the Apache 2.0 License in the LICENSE File.

Further Details
---------------
- [Project Page](http://piim.newschool.edu/healthboard)
- [Healthboard on OSEHRA](http://www.osehra.org/group/healthboard)
