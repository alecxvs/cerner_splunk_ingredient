cerner_splunk_ingredient Cookbook
=================================
Resource cookbook which provides custom resources for installing and managing Splunk.

These resources can:
- Install Splunk via downloadable package or archive
- Start and stop the Splunk service

Requirements
------------
Chef >= 12.4
Ruby >= 2.1.8

Supports Linux and Windows based systems with package support for Debian, Redhat,
and Windows.

Using resources of this cookbook to install and run Splunk means you agree to Splunk's EULA packaged with the software,
also available online at http://www.splunk.com/en_us/legal/splunk-software-license-agreement.html

---

Resources
---------

### splunk_install
Manages an installation of Splunk

##### Action *:install*
Installs Splunk or Universal Forwarder.

Properties:

| Name     |               Type(s)               | Required | Default                                                                   | Description                                                                                                                                                                                                                                                            |
|:---------|:-----------------------------------:|:--------:|:--------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| package  | `:splunk` or `:universal_forwarder` | **Yes**  |                                                                           | Specifies the Splunk package to install. You must specify the package, or name the resource for the package; for example, `package :splunk` or `splunk_install 'universal_forwarder' do ... end`                                                                       |
| version  |               String                | **Yes**  |                                                                           | Version of Splunk to install                                                                                                                                                                                                                                           |
| build    |               String                | **Yes**  |                                                                           | Build number of the version                                                                                                                                                                                                                                            |
| user     |               String                |    No    | Current user, or based on the package (`'splunk'` or `'splunkforwarder'`) | User that should own the splunk installation. Make sure you don't use a different user for running Splunk that has insufficient read/write access, or Splunk won't start!                                                                                              |
| base_url |               String                |    No    | `'https://download.splunk.com/products'`                                  | Base url to pull Splunk packages from. Use this if you are mirroring the downloads for Splunk packages. The resource will append the version, os, and filename to the url like so: `{base_url}/splunk/releases/0.0.0/linux/splunk-0.0.0-a1b2c3d4e5f6-Linux-x86_64.tgz` |

##### Action *:uninstall*
Removes Splunk or Universal Forwarder and all its configuration.

Properties:

| Name    |               Type(s)               | Required | Default | Description                                                                                                                                                                                        |
|:--------|:-----------------------------------:|:--------:|:--------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| package | `:splunk` or `:universal_forwarder` | **Yes**  |         | Specifies the Splunk package to uninstall. You must specify the package, or name the resource for the package; for example, `package :splunk` or `splunk_install 'universal_forwarder' do ... end` |

###### Run State

`splunk_install` *stores the current installation state to the [run state](https://docs.chef.io/recipes.html#node-run-state).*
This contains data such as install directory and package so that subsequent resources can assume these values and avoid
repetition. For example, you would be able to execute `splunk_conf` after a `splunk_install` and it will inherit the
package of that last evaluated resource. If the install resource does nothing (installation already exists), it will
still load the run state from the existing installation.

You can access this state from your own recipe or resource, too. An example of the run state:
```Ruby
node.run_state['splunk_ingredient'] = {
  'installations' => {
    '/opt/splunk' => {    # Install directory
      name: 'splunk',     # Resource name
      package: :splunk,
      version: '5.5.5',
      build: 'a1b2c3d4e5f6',
      x64: true           # Architecture of the Splunk install, determined by system supported architecture.
    }
  },
  'current_installation' => {
    name: 'splunk',
    package: :splunk,
    ...
    # References the last evaluated splunk_install; same as above, being the only install.
  }
}
```


### splunk_service
Manages an installation of Splunk. Requires splunk_install to be evaluated first.

**The following actions share the same properties:**

##### Action *:start*
Starts the Splunk daemon if not already running.
If the ulimit is changed, invokes a restart of the daemon at the end of the run.

##### Action *:restart*
Restarts the Splunk daemon, or starts it if not already running.

Properties:

| Name    |               Type(s)               | Required | Default                                            | Description                                                                                                                                                                                      |
|:--------|:-----------------------------------:|:--------:|:---------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| package | `:splunk` or `:universal_forwarder` | **Yes**  |                                                    | Specifies the Splunk package to install. You must specify the package, or name the resource for the package; for example, `package :splunk` or `splunk_install 'universal_forwarder' do ... end` |
| user    |            String or nil            |    No    | Owner of the specified Splunk installation, if any | User to run Splunk as. This is the user that will be used to run the Splunk service.                                                                                                             |
| ulimit  |               Integer               |    No    | Start up script ulimit or user ulimit              | Open file ulimit to give Splunk. This sets the ulimit in the start up script (if it exists) and for the given user in `/etc/security/limits.d/`. -1 translates to `'unlimited'`                  |

##### Action *:stop*
Stop the Splunk daemon if it is running.


Properties:

| Name    |               Type(s)               | Required | Default | Description                                                                                                                                                                                      |
|:--------|:-----------------------------------:|:--------:|:--------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| package | `:splunk` or `:universal_forwarder` | **Yes**  |         | Specifies the Splunk package to install. You must specify the package, or name the resource for the package; for example, `package :splunk` or `splunk_install 'universal_forwarder' do ... end` |


### splunk_conf
Manages configuration for an installation of Splunk. Requires splunk_install to be evaluated first.

##### Action *:configure*
Applies configuration to .conf files.
You should know where the .conf file is that you wish to modify, as you must provide the path from `$SPLUNK_HOME/etc`.

You can specify the scope as you would in the real path to the file (`system/local/indexes.conf`) or use the `scope`
property and specify this path: `system/indexes.conf`. The resource will modify local config if no scope is provided.

Properties:

| Name    |               Type(s)               | Required | Default                                          | Description                                                                                                                                                                                  |
|:--------|:-----------------------------------:|:--------:|:-------------------------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| path    |         String or Pathname          | **Yes**  |                                                  | Path of the .conf file from `$SPLUNK_HOME/etc`. The intermediate directory determining scope is optional. Examples: `system/indexes.conf` or `system/local/indexes.conf`.                    |
| package | `:splunk` or `:universal_forwarder` |    No    | Package of the current install in run state      | Specifies the Splunk package to install. You may specify the package (`:splunk` or `:universal_forwarder`) or the resource will refer to the most recently evaluated splunk_install resource |
| scope   |       `:local` or `:default`        |    No    | `:local`                                         | Scope of the configuration to modify. In most circumstances, you should *not* change this.                                                                                                   |
| config  |                Hash                 | **Yes**  |                                                  | Configuration to apply to the .conf file. This hash is structured as follows: `{ stanza: { key: 'value' } }`. See below for more detailed explanation of the config property.                |
| user    |            String or nil            |    No    | Owner of the current Splunk installation, if any | User that will be used to write to the .conf files.                                                                                                                                          |
| reset   |            true or false            |    No    | false                                            | When specified as true, entirely replaces existing config. By default, config is merged into the existing conf file.                                                                         |

##### Configuration
The configuration you provide will be evaluated against the existing config file (if it exists, and if reset is not specified).
Symbol or string keys are irrelevant as the provided config is converted to string keys and values before being used.

Some things to be aware of when using the configuration resource:

###### **"Global" properties are evaluated under `[default]`**
Properties defined at the top of the .conf file and not considered to be part of a stanza are assumed to be `[default]`
per Splunk documentation: http://docs.splunk.com/Documentation/Splunk/6.4.2/Admin/Propsconf#GLOBAL_SETTINGS

###### **Comments are not preserved**
The configuration resource can't evaluate and merge the configuration on disk and by Chef while keeping the
relevant comments and whitespace. The .conf file will be rewritten with the merged config and uniform whitespace.

###### **Example of how the configuration is written out to disk:**

```Ruby
splunk_conf 'system/test.conf' do
  config(
    testing: {
      one: 1,
      two: 2,
      three: 3
    },
    stanza: {
      key: :value
    }
  )
end
```

`/opt/splunk/etc/system/local/test.conf`:
```INI
# Warning: This file is managed by Chef!
# Comments will not be preserved and configuration may be overwritten.

[testing]
one = 1
two = 2
three = 3

[stanza]
key = value
```

---

Contributing
------------

Check out the [Github Guide to Contributing](https://guides.github.com/activities/contributing-to-open-source/)
for some basic tips on contributing to open source projects, and make sure to read our [Contributing Guidelines](CONTRIBUTING)
before submitting an issue or pull request.

License and Authors
-------------------
- Author:: Alec Sears (alec.sears@cerner.com)

```text
Copyright:: 2016, Cerner Innovation, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
