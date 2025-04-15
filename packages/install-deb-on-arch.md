# 🧾 Installing `.deb` Packages on Arch Linux

This guide shows how to convert and install `.deb` packages on Arch Linux using `makepkg`.

This is for those times that debtap does not work.

---

## ✅ 1. Set Up Workspace

```bash
mkdir -p ~/packages/someapp/{src,pkg}
cd ~/packages/someapp
cp /path/to/appname_x.y.z-amd64.deb .
```

---

## ✅ 2. Extract the `.deb`

Make sure dpkg is installed before this.

```bash
dpkg-deb -x appname_x.y.z-amd64.deb src/
```

---

## ✅ 3. Create the `PKGBUILD`

In the same folder, create a file named `PKGBUILD`:

```bash
nano PKGBUILD
```

Paste this:

```bash
pkgname=appname
pkgver=x.y.z
pkgrel=1
pkgdesc="Description of the app"
arch=('x86_64')
url="https://example.com"
license=('custom')
depends=('glibc')  # Add more as needed
source=()
package() {
  cp -r "$srcdir/etc" "$pkgdir/etc"
  cp -r "$srcdir/usr" "$pkgdir/usr"

  # Optional: if binary is hidden deep
  install -d "$pkgdir/usr/bin"
  ln -s /usr/share/AppDir/bin/app "$pkgdir/usr/bin/app"
}
```

Adjust paths and binary location as needed.

Dependencies can be checkd using ldd against the binary.

AI is relatively good at:
  - determining the actual packages with the ldd output
  - finding the binary if you give it tree output of the src dir
  - updating PKGBUILD

---

## ✅ 4. Build and Install

Pacman can be replaced with Paru here.

```bash
makepkg -f
sudo pacman -U appname-x.y.z-1-x86_64.pkg.tar.zst
```

---

## 🧼 Optional: Clean Up

```bash
rm -rf ~/packages/myapp
```

---

Now you should be able to test the package!
