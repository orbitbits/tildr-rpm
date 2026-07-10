%global app_name tildr
%global github_repo https://github.com/orbitbits/tildr
%global github_branch main

Name:           %{app_name}
Version:        0.1.0
Release:        1%{?dist}
Summary:        Manage HOME files and directories with symlinks and Git
License:        LicenseRef-ElasticLicense2.0
URL:            https://orbitbits.com/tildr
Source0:        %{app_name}-%{version}-linux-x86_64
Source1:        %{app_name}.1
Source2:        %{app_name}-config.1
Source3:        %{app_name}-commands.1
Source4:        %{app_name}-security.1
Source5:        %{app_name}-plugins.1
Source6:        %{app_name}.py
Source7:        %{app_name}.desktop
Source8:        LICENSE

BuildArch:      x86_64
Requires:       git
Requires:       less

Recommends:     nautilus-python
Recommends:     kf5-dolphin

Provides:       %{app_name} = %{version}-%{release}
Conflicts:      %{app_name}

%description
Tildr is a declarative CLI tool for managing your Linux HOME directory
using symlinks and Git. It provides a simple way to dotfile management
across multiple machines.

%prep
%setup -q -c %{name}-%{version} -n %{name}-%{version}

%build
cp %{SOURCE0} %{app_name}

%install
mkdir -p %{buildroot}%{_bindir}
install -Dm755 %{app_name} %{buildroot}%{_bindir}/%{app_name}

mkdir -p %{buildroot}%{_mandir}/man1
install -Dm644 %{SOURCE1} %{buildroot}%{_mandir}/man1/%{app_name}.1
install -Dm644 %{SOURCE2} %{buildroot}%{_mandir}/man1/%{app_name}-config.1
install -Dm644 %{SOURCE3} %{buildroot}%{_mandir}/man1/%{app_name}-commands.1
install -Dm644 %{SOURCE4} %{buildroot}%{_mandir}/man1/%{app_name}-security.1
install -Dm644 %{SOURCE5} %{buildroot}%{_mandir}/man1/%{app_name}-plugins.1

mkdir -p %{buildroot}%{_datadir}/nautilus-python/extensions
install -Dm644 %{SOURCE6} %{buildroot}%{_datadir}/nautilus-python/extensions/%{app_name}.py

mkdir -p %{buildroot}%{_datadir}/kio/servicemenus
install -Dm644 %{SOURCE7} %{buildroot}%{_datadir}/kio/servicemenus/%{app_name}.desktop

mkdir -p %{buildroot}%{_datadir}/licenses/%{name}
install -Dm644 %{SOURCE8} %{buildroot}%{_datadir}/licenses/%{name}/LICENSE

%files
%license %{_datadir}/licenses/%{name}/LICENSE
%doc %{_mandir}/man1/%{app_name}.1*
%doc %{_mandir}/man1/%{app_name}-config.1*
%doc %{_mandir}/man1/%{app_name}-commands.1*
%doc %{_mandir}/man1/%{app_name}-security.1*
%doc %{_mandir}/man1/%{app_name}-plugins.1*
%attr(755,root,root) %{_bindir}/%{app_name}
%{_datadir}/nautilus-python/extensions/%{app_name}.py
%{_datadir}/kio/servicemenus/%{app_name}.desktop
