mPrinter iOS library
====================

This library allows for direct printing to mPrinter printers from iOS devices.  It includes a basic discovery protocol, image, text, and HTML printing.

Sample application
==================

The mPrinter Test project contains a minimal library implementation showing feeding, printing text and images, and printer discovery.

Using the library
=================

To use this library, perform the following:

1. Add the library project file **mPrinter.xcodeproj** to your existing project.
2. Add the **mPrinter.bundle** file to your project.  This can be found in the *mPrinter Test* application.
3. Make sure your project includes CFNetwork and Security framrworks.
4. Add **libmPrinter.a** to "Build Phases" on your project target.

If you experience issues linking or including headers, it may be necessary to add *-all_load* to *Other Linker Flags* in your target build settings.
