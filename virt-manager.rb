class VirtManager < Formula
  include Language::Python::Virtualenv

  desc "App for managing virtual machines"
  homepage "https://virt-manager.org/"
  url "https://virt-manager.org/download/sources/virt-manager/virt-manager-2.2.1.tar.gz"
  sha256 "cfd88d66e834513e067b4d3501217e21352fadb673103bacb9e646da9f029a1b"
  revision 3

  depends_on "intltool" => :build
  depends_on "pkg-config" => :build

  depends_on "adwaita-icon-theme"
  depends_on "gtk+3"
  depends_on "gtk-vnc"
  depends_on "gtksourceview4"
  depends_on "hicolor-icon-theme"
  depends_on "libosinfo"
  depends_on "libvirt"
  depends_on "libvirt-glib"
  depends_on "libxml2" # need python3 bindings
  depends_on "osinfo-db"
  depends_on "py3cairo"
  depends_on "pygobject3"
  depends_on "python"
  depends_on "spice-gtk"
  depends_on "vte3"

  resource "libvirt-python" do
    url "https://libvirt.org/sources/python/libvirt-python-7.1.0.tar.gz"
    sha256 "faafd31e407f9cb750a73349c007651ca8954ebd455e55b0a20e96de81c50037"
  end

  resource "idna" do
    url "https://pypi.io/packages/source/i/idna/idna-2.10.tar.gz"
    sha256 "b307872f855b18632ce0c21c5e45be78c0ea7ae4c15c828c20788b26921eb3f6"
  end

  resource "certifi" do
    url "https://pypi.io/packages/source/c/certifi/certifi-2020.12.5.tar.gz"
    sha256 "1a4995114262bffbc2413b159f2a1a480c969de6e6eb13ee966d470af86af59c"
  end

  resource "chardet" do
    url "https://pypi.io/packages/source/c/chardet/chardet-4.0.0.tar.gz"
    sha256 "0d6f53a15db4120f2b08c94f11e7d93d2c911ee118b6b30a04ec3ee8310179fa"
  end

  resource "urllib3" do
    url "https://pypi.io/packages/source/u/urllib3/urllib3-1.26.2.tar.gz"
    sha256 "19188f96923873c92ccb987120ec4acaa12f0461fa9ce5d3d0772bc965a39e08"
  end

  resource "requests" do
    url "https://pypi.io/packages/source/r/requests/requests-2.25.1.tar.gz"
    sha256 "27973dd4a904a4f13b263a19c866c13b92a39ed1c964655f025f3f8d3d75b804"
  end

  # virt-manager doesn't prompt for password on macOS unless --no-fork flag is provided
  patch :DATA

  def install
    venv = virtualenv_create(libexec, "python3")
    venv.pip_install resources

    # virt-manager uses distutils, doesn't like --single-version-externally-managed
    system "#{libexec}/bin/python", "setup.py",
                     "configure",
                     "--prefix=#{libexec}"
    system "#{libexec}/bin/python", "setup.py",
                     "--no-user-cfg",
                     "--no-update-icon-cache",
                     "--no-compile-schemas",
                     "install"

    # install virt-manager commands with PATH set to Python virtualenv environment
    bin.install Dir[libexec/"bin/virt-*"]
    bin.env_script_all_files(libexec/"bin", :PATH => "#{libexec}/bin:$PATH")

    share.install Dir[libexec/"share/man"]
    share.install Dir[libexec/"share/glib-2.0"]
    share.install Dir[libexec/"share/icons"]
  end

  def post_install
    # manual schema compile step
    system "#{Formula["glib"].opt_bin}/glib-compile-schemas", "#{HOMEBREW_PREFIX}/share/glib-2.0/schemas"
    # manual icon cache update step
    system "#{Formula["gtk+3"].opt_bin}/gtk3-update-icon-cache", "#{HOMEBREW_PREFIX}/share/icons/hicolor"
  end

  test do
    system "#{bin}/virt-manager", "--version"
  end
end
__END__
diff --git a/virt-manager b/virt-manager
index 15d5109..8ee305a 100755
--- a/virt-manager
+++ b/virt-manager
@@ -151,7 +151,8 @@ def parse_commandline():
         help="Print debug output to stdout (implies --no-fork)",
         default=False)
     parser.add_argument("--no-fork", action="store_true",
-        help="Don't fork into background on startup")
+        help="Don't fork into background on startup",
+        default=True)

     parser.add_argument("--show-domain-creator", action="store_true",
         help="Show 'New VM' wizard")
