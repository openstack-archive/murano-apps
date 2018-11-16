Style Guidelines
================

Step 1: Read the  `OpenStack Style Guidelines`_.

Step 2: Read on

Commit Messages
---------------

The common OpenStack guideline related to commit messages can be found at the `official guideline`_.

Further guidance contains additional agreements which are specific to the `Murano Applications repository`_.

Start a message title with the name of a particular application related to your change enclosed in brackets.
If a commit is related to a group of applications that have a separate folder in the repository,
add the directory path before the application name.

Correct

.. code-block:: console

    [Rally] Deployment fixed

..

Incorrect

.. code-block:: console

    Fix deployment of Rally application

..

If the application belongs to a particular group and is located in a subfolder, then use the group name as a prefix.

.. code-block:: console

    [Windows][ActiveDirectory] Default recovery password removed

..

If it is an initial commit for an application, the title should look like this:

.. code-block:: console

    [Docker][Elasticsearch] Application added

..

In case the commit is not related to any application, do not use a prefix.

.. _`Murano Applications repository`: https://github.com/openstack/murano-apps
.. _official guideline: https://docs.openstack.org/hacking/latest/#commit-messages
.. _`OpenStack Style Guidelines`: https://docs.openstack.org/hacking/latest/
