==============================
Murano Applications Repository
==============================

Contains Murano Application packages source code.
All current applications supposed to work on Ubuntu Trusty with murano-agent installed.
Other Ubuntu versions are not tested.

Composing an application package
--------------------------------

Murano Applications are imported as zip archives, so
to make an application ready to use in Murano, it should be zipped first.

To make a valid murano package take *package* folder located under
application directory and zip it's content. Make sure new archive
doesn't contain *package* folder itself. For more information, refer to
`Murano documentation <http://murano.readthedocs.org/>`_.

Importing application package
-----------------------------

* Use murano dashboard to import packages.
  Go to *Murano > Manage > Package Definitions*
  and press *Import Package*

* Use murano CLI ``murano package-import``

* Local zip file, URL or package name, located in Murano repository can be provided

Building DIB elements for application image
-------------------------------------------

Please, refer to *readme.rst* file located at application
folder to find out how to build image for a specific application.

DIB elements with which image should be build are located at *elements* folder
at the same level with *package* folder.
If application folder doesn't contain *elements* inside - it means,
that no other preparation except murano-agent is needed.