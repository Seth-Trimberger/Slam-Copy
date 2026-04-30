%[text] ## Software Library for Analysis in Matlab (SLAM)
%[text] Started November 2024 by Daniel Dolan
%[text] Institute for Shock Physics
%[text] Washington State University
%%
%[text] ### Getting started
%[text] Begin by placing the toolbox at a convenient location.  For best results, the parent folder of the help subfolder (which contains this document) should be named SLAMtoolbox; depending on how the repository was obtained, this folder may have a different name, possibly ending in `-main`.  Run the `createStartupFile` function adjacent with this file creates/modifies the `startup.m` file so that SLAM can be called from any location.  **Then move to different folder--user code and data should not be placed inside the repository**.
%[text] The command `doc SLAM` provides top-level documentation for the SLAM package/namespace, where on can tunnel down to particular features of interest.  Direct access to a specific feature is also permitted, such as `doc SLAM.Reference.CODATA`.
%%
%[text] ### Background 
%[text] under construction
%%
%[text] ### Conventions
%[text] SLAM is meant to be as self contained as possible.  Unless there is a compelling reason to deviate from this principle, code contained with the library should not rely upon anything but MATLAB and itself.  In other words, reliance on the various Mathworks toolboxes is discouraged to maximize portability between different systems/users.  Deviations from this principle will be considered on a case by case basis and should be explicitly documented.
%[text] External code can be incorporated into SLAM as allowed by the license copyright.  For example, the Mathworks File Exchange provides a wealth of MATLAB capabilities that do not need to be written from scratch.  When those capabilities are incorporated into SLAM, the original code and any supplemental files (particularly `license.txt`) should be archived in a folder adjacent to a public interface.  An example of this practice is `SLAM.Math.Faddeeva`, which is based on fadf.m from the File Exchange.  The function `Faddeeva.m` uses code from `fadf.m`, and the folder `Faddeeva` has the original copy, license file, and readme file.
%[text] 

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":33}
%---
