Most likely will not end as planned.

cd ~/chard
curl -LO https://archlinux.org/packages/extra/x86_64/wget/download
mv download wget-1.25.0-2-x86_64.pkg.tar.zst
unzstd wget-1.25.0-2-x86_64.pkg.tar.zst
tar -xvf wget-1.25.0-2-x86_64.pkg.tar

cat > ~/chard/nosudo.sh <<'EOF'
#!/bin/bash
echo "test"
EOF

chmod +x ~/chard/nosudo.sh

bash ~/chard/nosudo

don't run this:

<pre> bash <(curl -s "https://raw.githubusercontent.com/shadowed1/Chard/main/chard_installer.sh?$(date +%s)") </pre>
