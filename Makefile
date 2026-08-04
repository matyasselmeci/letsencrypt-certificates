sources = isrgrootx1.signing_policy \
          isrg-root-x2.signing_policy \
          lets-encrypt-e5.signing_policy \
          lets-encrypt-e6.signing_policy \
          lets-encrypt-r10.signing_policy \
          lets-encrypt-r11.signing_policy \
          lets-encrypt-e7.signing_policy \
          lets-encrypt-e8.signing_policy \
          lets-encrypt-e9.signing_policy \
          lets-encrypt-r12.signing_policy \
          lets-encrypt-r13.signing_policy \
          lets-encrypt-r14.signing_policy \
          isrg-root-ye.signing_policy \
          isrg-root-yr.signing_policy \
          lets-encrypt-ye1.signing_policy \
          lets-encrypt-ye2.signing_policy \
          lets-encrypt-ye3.signing_policy \
          lets-encrypt-yr1.signing_policy \
          lets-encrypt-yr2.signing_policy \
          lets-encrypt-yr3.signing_policy

targets = 4042bcee.signing_policy \
          6187b673.signing_policy \
          0b9bc432.signing_policy 8794b4e3.signing_policy \
          462422cf.signing_policy bae39ced.signing_policy \
          9aad238c.signing_policy f7679d31.signing_policy \
          aa578057.signing_policy 09e5bea5.signing_policy \
          31dfb39d.signing_policy 4cdd6f92.signing_policy \
          67561239.signing_policy 9f308661.signing_policy \
          507754fb.signing_policy 3e7e99ec.signing_policy \
          d0a3aef2.signing_policy 35b815f3.signing_policy \
          aa76c4ab.signing_policy 93120419.signing_policy \
          4260b799.signing_policy 27794265.signing_policy \
          137e9a94.signing_policy 36f5bce7.signing_policy \
          51e2f20f.signing_policy 8ed85ee6.signing_policy \
          558fe057.signing_policy 05e55783.signing_policy \
          a075c285.signing_policy 1a416bbd.signing_policy \
          6b1d43b5.signing_policy 727e8638.signing_policy \
          01212e5d.signing_policy efd1bceb.signing_policy \
          a363cdd3.signing_policy 2f8a4f35.signing_policy \
          cde2be7c.signing_policy 74303716.signing_policy \
          66297767.signing_policy c1af242b.signing_policy \
          4042bcee.0 \
          6187b673.0 \
          0b9bc432.0 8794b4e3.0 \
          462422cf.0 bae39ced.0 \
          9aad238c.0 f7679d31.0 \
          aa578057.0 09e5bea5.0 \
          31dfb39d.0 4cdd6f92.0 \
          67561239.0 9f308661.0 \
          507754fb.0 3e7e99ec.0 \
          d0a3aef2.0 35b815f3.0 \
          aa76c4ab.0 93120419.0 \
          4260b799.0 27794265.0 \
          137e9a94.0 36f5bce7.0 \
          51e2f20f.0 8ed85ee6.0 \
          558fe057.0 05e55783.0 \
          a075c285.0 1a416bbd.0 \
          6b1d43b5.0 727e8638.0 \
          01212e5d.0 efd1bceb.0 \
          a363cdd3.0 2f8a4f35.0 \
          cde2be7c.0 74303716.0 \
          66297767.0 c1af242b.0 \


pems = \
          isrgrootx1.pem \
          isrg-root-x2.pem \
          lets-encrypt-e5.pem \
          lets-encrypt-e6.pem \
          lets-encrypt-r10.pem \
          lets-encrypt-r11.pem \
          lets-encrypt-e7.pem \
          lets-encrypt-e8.pem \
          lets-encrypt-e9.pem \
          lets-encrypt-r12.pem \
          lets-encrypt-r13.pem \
          lets-encrypt-r14.pem \
          isrg-root-ye.pem \
          isrg-root-yr.pem \
          lets-encrypt-ye1.pem \
          lets-encrypt-ye2.pem \
          lets-encrypt-ye3.pem \
          lets-encrypt-yr1.pem \
          lets-encrypt-yr2.pem \
          lets-encrypt-yr3.pem

installfiles = $(pems) $(targets) $(sources)

installdir = /etc/grid-security/certificates

GET = curl -O
GET_WITH_NAME = curl -o
INSTALL = install
LINK = ln -s

all : $(pems) $(targets)

install : all
	$(INSTALL) $(installfiles) $(DESTDIR)$(installdir)

clean :
	$(RM) $(targets) *.pem

check : all
	openssl verify -CApath . isrgrootx1.pem
	openssl verify -CApath . isrg-root-x2.pem
	openssl verify -CApath . lets-encrypt-e5.pem
	openssl verify -CApath . lets-encrypt-e6.pem
	openssl verify -CApath . lets-encrypt-r10.pem
	openssl verify -CApath . lets-encrypt-r11.pem
	openssl verify -CApath . lets-encrypt-e7.pem
	openssl verify -CApath . lets-encrypt-e8.pem
	openssl verify -CApath . lets-encrypt-e9.pem
	openssl verify -CApath . lets-encrypt-r12.pem
	openssl verify -CApath . lets-encrypt-r13.pem
	openssl verify -CApath . lets-encrypt-r14.pem
	openssl verify -CApath . isrg-root-ye.pem
	openssl verify -CApath . isrg-root-yr.pem
	openssl verify -CApath . lets-encrypt-ye1.pem
	openssl verify -CApath . lets-encrypt-ye2.pem
	openssl verify -CApath . lets-encrypt-ye3.pem
	openssl verify -CApath . lets-encrypt-yr1.pem
	openssl verify -CApath . lets-encrypt-yr2.pem
	openssl verify -CApath . lets-encrypt-yr3.pem

pems : $(pems)

# make special variables: $< is the first prereq; $@ is the target

4042bcee.signing_policy 6187b673.signing_policy : isrgrootx1.signing_policy
	$(LINK) $< $@
0b9bc432.signing_policy 8794b4e3.signing_policy : isrg-root-x2.signing_policy
	$(LINK) $< $@
462422cf.signing_policy bae39ced.signing_policy : lets-encrypt-e5.signing_policy
	$(LINK) $< $@
9aad238c.signing_policy f7679d31.signing_policy : lets-encrypt-e6.signing_policy
	$(LINK) $< $@
aa578057.signing_policy 09e5bea5.signing_policy : lets-encrypt-r10.signing_policy
	$(LINK) $< $@
31dfb39d.signing_policy 4cdd6f92.signing_policy : lets-encrypt-r11.signing_policy
	$(LINK) $< $@
67561239.signing_policy 9f308661.signing_policy : lets-encrypt-e7.signing_policy
	$(LINK) $< $@
507754fb.signing_policy 3e7e99ec.signing_policy : lets-encrypt-e8.signing_policy
	$(LINK) $< $@
d0a3aef2.signing_policy 35b815f3.signing_policy : lets-encrypt-e9.signing_policy
	$(LINK) $< $@
aa76c4ab.signing_policy 93120419.signing_policy : lets-encrypt-r12.signing_policy
	$(LINK) $< $@
4260b799.signing_policy 27794265.signing_policy : lets-encrypt-r13.signing_policy
	$(LINK) $< $@
137e9a94.signing_policy 36f5bce7.signing_policy : lets-encrypt-r14.signing_policy
	$(LINK) $< $@
51e2f20f.signing_policy 8ed85ee6.signing_policy : isrg-root-ye.signing_policy
	$(LINK) $< $@
558fe057.signing_policy 05e55783.signing_policy : isrg-root-yr.signing_policy
	$(LINK) $< $@
a075c285.signing_policy 1a416bbd.signing_policy : lets-encrypt-ye1.signing_policy
	$(LINK) $< $@
6b1d43b5.signing_policy 727e8638.signing_policy : lets-encrypt-ye2.signing_policy
	$(LINK) $< $@
01212e5d.signing_policy efd1bceb.signing_policy : lets-encrypt-ye3.signing_policy
	$(LINK) $< $@
a363cdd3.signing_policy 2f8a4f35.signing_policy : lets-encrypt-yr1.signing_policy
	$(LINK) $< $@
cde2be7c.signing_policy 74303716.signing_policy : lets-encrypt-yr2.signing_policy
	$(LINK) $< $@
66297767.signing_policy c1af242b.signing_policy : lets-encrypt-yr3.signing_policy
	$(LINK) $< $@


4042bcee.0 6187b673.0 : isrgrootx1.pem
	$(LINK) $< $@
0b9bc432.0 8794b4e3.0 : isrg-root-x2.pem
	$(LINK) $< $@
462422cf.0 bae39ced.0 : lets-encrypt-e5.pem
	$(LINK) $< $@
9aad238c.0 f7679d31.0 : lets-encrypt-e6.pem
	$(LINK) $< $@
aa578057.0 09e5bea5.0 : lets-encrypt-r10.pem
	$(LINK) $< $@
31dfb39d.0 4cdd6f92.0 : lets-encrypt-r11.pem
	$(LINK) $< $@
67561239.0 9f308661.0 : lets-encrypt-e7.pem
	$(LINK) $< $@
507754fb.0 3e7e99ec.0 : lets-encrypt-e8.pem
	$(LINK) $< $@
d0a3aef2.0 35b815f3.0 : lets-encrypt-e9.pem
	$(LINK) $< $@
aa76c4ab.0 93120419.0 : lets-encrypt-r12.pem
	$(LINK) $< $@
4260b799.0 27794265.0 : lets-encrypt-r13.pem
	$(LINK) $< $@
137e9a94.0 36f5bce7.0 : lets-encrypt-r14.pem
	$(LINK) $< $@
51e2f20f.0 8ed85ee6.0 : isrg-root-ye.pem
	$(LINK) $< $@
558fe057.0 05e55783.0 : isrg-root-yr.pem
	$(LINK) $< $@
a075c285.0 1a416bbd.0 : lets-encrypt-ye1.pem
	$(LINK) $< $@
6b1d43b5.0 727e8638.0 : lets-encrypt-ye2.pem
	$(LINK) $< $@
01212e5d.0 efd1bceb.0 : lets-encrypt-ye3.pem
	$(LINK) $< $@
a363cdd3.0 2f8a4f35.0 : lets-encrypt-yr1.pem
	$(LINK) $< $@
cde2be7c.0 74303716.0 : lets-encrypt-yr2.pem
	$(LINK) $< $@
66297767.0 c1af242b.0 : lets-encrypt-yr3.pem
	$(LINK) $< $@


# Look for the `pem` links on < https://letsencrypt.org/certificates/ >.
# Download the "self-signed" root CAs, not the cross-signed ones.
# Include the ones marked "backup".
isrgrootx1.pem :
	$(GET) https://letsencrypt.org/certs/isrgrootx1.pem
isrg-root-x2.pem :
	$(GET) https://letsencrypt.org/certs/isrg-root-x2.pem
lets-encrypt-e5.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/2024/e5.pem
lets-encrypt-e6.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/2024/e6.pem
lets-encrypt-r10.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/2024/r10.pem
lets-encrypt-r11.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/2024/r11.pem
lets-encrypt-e7.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/2024/e7.pem
lets-encrypt-e8.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/2024/e8.pem
lets-encrypt-e9.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/2024/e9.pem
lets-encrypt-r12.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/2024/r12.pem
lets-encrypt-r13.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/2024/r13.pem
lets-encrypt-r14.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/2024/r14.pem
isrg-root-ye.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/gen-y/root-ye.pem
isrg-root-yr.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/gen-y/root-yr.pem
lets-encrypt-ye1.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/gen-y/int-ye1.pem
lets-encrypt-ye2.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/gen-y/int-ye2.pem
lets-encrypt-ye3.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/gen-y/int-ye3.pem
lets-encrypt-yr1.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/gen-y/int-yr1.pem
lets-encrypt-yr2.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/gen-y/int-yr2.pem
lets-encrypt-yr3.pem :
	$(GET_WITH_NAME) $@ https://letsencrypt.org/certs/gen-y/int-yr3.pem


