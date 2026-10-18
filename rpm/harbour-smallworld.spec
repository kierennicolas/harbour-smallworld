Name:       harbour-smallworld
Summary:    Unofficial app for the ASMALLWORLD website
Version:    0.1.0
Release:    1
Group:      Qt/Qt
License:    MIT
BuildArch:  noarch
URL:        https://github.com/kierennicolas/harbour-smallworld
Source0:    %{name}-%{version}.tar.bz2

Requires:       sailfishsilica-qt5 >= 0.10.9
Requires:       libsailfishapp-launcher
Requires:       sailfish-components-webview-qt5
Requires:       sailfish-components-webview-qt5-popups
Requires:       sailfish-components-webview-qt5-pickers
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
Small World shows the ASMALLWORLD website (asmallworld.com) in a native
Sailfish OS app with its own icon, cover and toolbar. It is not made or
endorsed by ASMALLWORLD AG.

%prep
%autosetup -n %{name}-%{version}

%build
%qmake5
%make_build

%install
%qmake5_install
sed -i 's/@VERSION@/%{version}/' %{buildroot}%{_datadir}/%{name}/qml/pages/AboutPage.qml
desktop-file-install --delete-original --dir %{buildroot}%{_datadir}/applications %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
