================
SugarCRM v6.5.22
================

This package deploys the version 6.5.22 of SugarCRM CE.
SugarCRM is a customer relationship management software. Its Community
Edition is opensourced and is distributed under a GNU Affero General Public
License.


Deployment workflow:
--------------------

During the app deployment the following steps are executed:

* the deployment of WebServer and RDBMS servers are verified

* a database and a user are created ay RDBMS, the user is granted needed
permissions

* the needed pre-requisites are installed on a web server

* the binary archive containing the software is downloaded from a temporary
dropbox location

* the archive is extracted to Apache html directory, appropriate permissions
are set

* a silent install config is created and parameterised with user input

* a silent installation is initiated by a curl call


Actions:
--------

The following actions are available:

* *clear* - reset the database contents to a clean initial state

* *populateDemoData* - reset the database contents and populates it with a
demonstration data
