%global app_name tildr

Name:           %{app_name}
Version:        0.3.2
Release:        1%{?dist}
Summary:        Manage HOME files and directories with symlinks and Git
License:        GNU AFFERO GENERAL PUBLIC LICENSE
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
mkdir -p %{name}-%{version}
cp %{SOURCE0} %{name}-%{version}/
cp %{SOURCE1} %{SOURCE2} %{SOURCE3} %{SOURCE4} %{SOURCE5} %{name}-%{version}/
cp %{SOURCE6} %{SOURCE7} %{SOURCE8} %{name}-%{version}/

%build
cp %{SOURCE0} %{app_name}
chmod 755 %{app_name}

%check
test -x %{app_name}

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

%changelog
* Thu Jul 23 2026 William Canin <hello.williamcanin@gmail.com> - 0.3.2-1
- Update to version 0.3.2
- Change license to GNU AGPL-3.0

* Wed Jul 22 2026 William Canin <hello.williamcanin@gmail.com> - 0.3.1-1
- Update to version 0.3.1

* Tue Jul 21 2026 William Canin <hello.williamcanin@gmail.com> - 0.3.0-1
- Update to version 0.3.0

* Fri Jul 18 2026 William Canin <hello.williamcanin@gmail.com> - 0.2.0-1
- Update to version 0.2.0

* Fri Jul 10 2026 William Canin <hello.williamcanin@gmail.com> - 0.1.0-1
- Initial RPM package
