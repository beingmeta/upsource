Name:           upsource
Version:        0.5
Release:        1
Summary:        utility/compatability for Unicode and other functions

Group:          System Environment/Libraries
License:        GNU LGPL
URL:            http://www.beingmeta.com/
Source0:        libu8-2.5.4.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:
Requires:

%description
Provides for a configuration file which maps file system 
locations to various sources (e.g. git or svn).

%package        core
Summary:        Basic functionality
Group:          Development/Libraries
Requires:       %{name} = %{version}-%{release}

%description    core
The %{name}-core package contains the basic executables and directory structure for upsource but without some common handlers (for git, svn, s3, etc)

%package        git
Summary:        GIT handlers/support for upsource
Group:          Development/Libraries
Requires:       %{name} = %{version}-%{release}

%description    subversion
Provides support for subversion sources

%package        s3
Summary:        Subversion handlers/support for upsource
Group:          Development/Libraries
Requires:       %{name} = %{version}-%{release}

%description    s3
Provides support for subversion sources

%prep
%setup -q


%build
make

%install
rm -rf $RPM_BUILD_ROOT
make install install-docs DESTDIR=$RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%files core
%{_bindir}/upsource
%{_libdir}/upsource/sourcetab.awk
%{_libdir}/upsource/handlers/link.upsource
%{_libdir}/upsource/handlers/pre.sh
%{_libdir}/upsource/handlers/post.sh
/etc/upsource.d/config

%files git
%{_libdir}/upsource/handlers/git.upsource

%files subversion
%{_libdir}/upsource/handlers/svn.upsource

%files s3
%{_libdir}/upsource/handlers/s3.upsource

%changelog
* Mon Dec 5 2016 beingmeta repository manager <repoman@beingmeta.com> 0.5
Initial RPM spec

