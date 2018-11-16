# Installing DESI Dependencies with VirtualEnv and Pip

Conda is a great package manager for long-lived installations where packages
need to be updated consistently or when complicated package dependencies
need to be handled.  In some cases (e.g. integration testing and one-off
installs) we can just use a native python virtualenv and pip install our
python dependencies.

## Installing OS Packages

For large compiled packages, we want to just install these using the OS
package manager.  For Ubuntu / Debian systems this is APT, and for Redhat /
CentOS this is yum.  On OS X, we use ....

```
%>  sudo ./ubuntu_18.04.sh
```

OR

```
%>  sudo ./osx_macports.sh
```

## Create a virtualenv

Create a virtualenv for DESI dependencies:

```
$>  virtualenv -p python3.6 ${HOME}/software/desibase
```

Now activate this environment before proceeding:

```
$>  source ${HOME}/software/desibase/bin/activate
```

## Install Dependencies

Once your virtualenv is activated, run the install script for your OS.  For
example:

```
$>  ./virtualenv_linux.sh
```

OR

```
$>  ./virtualenv_osx.sh
```

Afterwards, you can activate the virtualenv and make the compiled packages
available with:

```
$>  source ${HOME}/software/desibase/setup.sh
```

## Install DESI packages

This is outside the scope of the "desiconda" git repo, since the only focus
here is on DESI **dependencies**.  However, one easy way to install the
the latest stable release of all DESI packages is to use the "desibuild"
tool.  We are going to put our git checkouts in a "git" subdirectory for
this example.  First clone it:

```
$>  mkdir ~/git; cd ~/git
$>  git clone https://github.com/tskisner/desibuild.git
```

Next, checkout the latest tagged releases of all packages:

```
$>  ./desibuild/desi_source --gitdir . \
    --versions ./desibuild/systems/versions_stable_https.txt
```

Install all packages:

```
$>  ./desibuild/desi_setup --gitdir . \
    --versions ./desibuild/systems/versions_stable_https.txt \
    --prefix ${HOME}/software/desi
```

Putting it all together, to load the dependencies and the DESI packages:

```
$>  source ${HOME}/software/desibase/setup.sh
$>  source ${HOME}/software/desi/setup.sh
```

See the desibuild documentation for more information about installing multiple
versions of DESI packages with modulefiles, setting defaults, etc.
