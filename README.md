# PrincesOfPaypal
A security write-up about the Paypal API &amp; data leakage

### Siphon $1/4mil from hundreds of Paypal accounts ~ freaky PayPal API

<p align="center">
<img src="http://i.imgur.com/lqmdxLv.gif"/>
</p>



## Disclaimer

This is for Educational purposes ONLY. First of all, this paper aims to alarm people about security issues concerning **data leakage**. This paper and PoC were written by me(d3f4ult) & a whitehat security researcher who wishes to remain nameless in fear of reprocussions at his day job.

**IT COULD HAVE FINANCIAL IMPACT && COST TO YOUR LIFE/COMPANY!!!**

"The fact is, I'm clearly a white hat but to make computer security move, I feel compelled to publicly disclose this.
Also, I would like to call software developers : "Guys ! Github is not your fucking dirty room" don't push sensitive data -- or bad code. This writeup is not about technical but education, about fixing mentality on how security concern is perceived."
  
"The only other ppl i know of to find this and use for personal gain was SEA, but they never revealed their technique. Obvious my crew could take the almost $1/4mil for ourselves but Paypal transactions can be tracked and reversed easily. However if routed through enough accs quick enough you could cashout most of it. Personally i love the chaos, its like Google's Project Zero droping 0day CVE's when vendors are dragging feet on viable patches. Security becomes stagnent when the bold do not act."

Whitehat Conclusion: **please DO NOT ROB innocent ppl** (imagine It could be your *grandma*).  

Blackhat Conclusion: **if you're gonna steal, make sure the target deserves it**.


- - -

#### Give me your token, I will tell you who you are

[**OAuth**](https://tools.ietf.org/html/rfc6749) is an authorization framework widely used on social media.
it's mainly used to authenticate communication between applications.
For example, your Twitter account can be managed by your Spotify
application to share your top musics, etc.

Between them you find a token : a unique string able to authorize tasks in a scope.
This token is actually as important as your couple of login/password -- or family jewels.
I admit that stock it and prevent it from being compromised is a hard responsibility.

<p align="center">
<img height="300px" width="300px" src="https://upload.wikimedia.org/wikipedia/commons/b/b7/Unico_Anello.png"/>
</p>

#### PayPal NVP

In the same idea as OAuth tokens, we will focus on other kind of API authentication. PayPal offer an [**Name-Value Pair** (NVP)](https://developer.paypal.com/docs/classic/api/NVPAPIOverview/) API to payout.
NVP is basically credentials to authenticate you during API operation - as OAuth.
Noticed that PayPal provided a sandbox for development test purpose.

PayPal print this warning :

```
Important: You must protect the values for USER, PWD, and SIGNATURE in your
implementation. Consider storing these values in a secure location other than
your web server document root and setting the file permissions so that only the
system user that executes your ecommerce application can access it.
```

One method named [**MassPay**](https://developer.paypal.com/docs/classic/mass-pay/gs_MassPay/) allows ecommerce application to pay people giving a valid PayPal email address.

```
curl https://api-3t.sandbox.paypal.com/nvp \
  -s \
  --insecure \
  -d USER=AccountUsername         # Caller UserName \
  -d PWD=AccountPassword          # Caller Pswd \
  -d SIGNATURE=AccountSignature   # Caller Sig \
  -d METHOD=MassPay \             # MassPay Method
  -d VERSION=90 \
  -d RECEIVERTYPE=EmailAddress \
  -d CURRENCYCODE=USD \
  -d L_EMAIL0=foo@bar.com           # The first payout starts with "0" \
  -d L_AMT0=13.37                   # Profit ...
```

Another method give us the balance of an account with a method named [**GetBalance**](https://developer.paypal.com/docs/classic/api/merchant/GetBalance_API_Operation_NVP/).

```
curl https://api-3t.sandbox.paypal.com/nvp \
  -s \
  --insecure \
  -d USER=AccountUsername         # Caller UserName \
  -d PWD=AccountPassword          # Caller Pswd \
  -d SIGNATURE=AccountSignature   # Caller Sig \
  -d METHOD=GetBalance \          # GetBalance Method
  -d VERSION=90 \
  -d RETURNALLCURRENCIES=1
```
- - -

#### Collect credsxxx

*```"Given enough eyeballs, all bugs are shallow" - Linus's Law```*



To collect the raw material we will need the [Github vanilla search bar](https://github.com/search) or [GitMiner](https://github.com/danilovazb/GitMiner).

By profiling NVP credentials, we can notice that all signatures have a predictable pattern.

With some keywords we can find plenty of candies.

* [```api-3t.paypal.com``` ```api1```](https://github.com/search?utf8=✓&q=api-3t.paypal.com+api1&type=Code&ref=searchresults) ```We’ve found 4,800 code results```

* [```api-3t.paypal.com``` ```api1``` ```live```](https://github.com/search?utf8=✓&q=api-3t.paypal.com+api1+live&type=Code&ref=searchresults) ```We’ve found 3,300 code results```

* [```api-3t.paypal.com``` ```api1``` ```live``` ```masspay```](https://github.com/search?utf8=✓&q=api-3t.paypal.com+api1+live+masspay&type=Code&ref=searchresults) ```We’ve found 42 code results```



- - -

#### PoC

For this part of the PoC we coded several scripts to help automate the process. First we wrote a simple bash script for doing single Paypal API requests to check credentials(paypal_balance.sh). The original reasoning for this was because some of the credentials returned with a security header error indicating either the credentials were incorrect or the requests wasnt using the correct VERSION. Here is an example of a failed GetBalance call:
<p align="center">
<img src="http://i.imgur.com/mweQJ1D.png"/>
</p>
Eventually we got extremely tired of customizing the API request by changing the parameters everytime and decided to write another script for mass checking(paypal_mass_getbalance.sh). This bash script would awk input from a file as variables for the creds and loop until all have been checked. **This was the best decision we made...** This allowed us to speed up the process by automating the scanning of 1000's of creds we had scraped from Github. Granted there were plenty requests that didnt work because they were using an older version than, VERSION=90. When testing our first scraped list of creds, most accounts were empty with the occasional SecurityHeader or NoPermission API errors:
<p align="center">
<img src="http://i.imgur.com/wKUmEAL.png"/>
</p>
However it should be noted, even if your Paypal is empty its still at risk. If MASSPAY is enabled then the account could be exploited to launder stolen funds through from other accounts. Or even be framed by depositing stolen funds into account and then sent to terrorists like the [Brian Krebs incident](http://krebsonsecurity.com/2015/12/2016-reality-lazy-authentication-still-the-norm/).

Eventually by our 4th list of scraped creds we started seeing accounts with **MASSIVE** amounts in them. This is just a small sample of all the rich accounts we found:
<p align="center">
<img src="http://i.imgur.com/UeI5sMT.png"/>
</p>
```
~ ./paypal_mass_getbalance.sh creds4.csv
Total: 105791 USD /O_O\
```

From these scans we then we compiled new creds.csv lists from all the active accounts found. Then we started checking these accounts to see if MASSPAY was enabled one by one. This is what a failed API MASSPAY call looks like:
<p align="center">
<img src="http://i.imgur.com/p1QGteU.png"/>
</p>


Once again we got tired of checking accounts one by one and wrote a new bash script for automating the process(paypal_masspay.sh). In a scan of almost 10,000 creds about 25% returned with Security Header or No Permission errors. Out of the remaining creds that correctly returned GetBalance amounts, about only 15% had MASSPAY enabled. However not all the accounts with MASSPAY enabled had money in them, but like we stated before they are still vulnerable to abuse. Here is what one of our Paypal MASSPAY scans looked like:
<p align="center">
<img src="http://i.imgur.com/9rqW7o1.png"/>
</p>


Basically we could have drained over a $1/4million from the +/-1125 exposed business accounts with MASSPAY enabled we found on Github. However one of us is a whitehat and the others have enough attention from law enforcement so we decided to disclose this publically instead of using or selling... FYI Paypal can EASILY be charged back once the person notices.

<p align="center">
<img src="http://media.giphy.com/media/HgRCL6irM8unm/giphy.gif"/>
</p>

##*```"For a short while we were Princes of Paypal..."```*


- - -

#### "Seriously, how can I prevent from data leakage ?"

* Do not disclose sensitive information on source code management system (*Github*) and/or social media (*Stackoverflow*).
* Work with private repository and/or custom Git.
* When you push configuration file : **DOUBLE CHECK if any sensitive data is in it!**.

#### If you pushed code with sensitive data

* **CONSIDER YOURSELF COMPROMISED!!!**.
* Revoke your token immediately, or else...
* ***"I guess you could call it a "failure", but I prefer the term "learning experience"." — Andy Weir***
* ***"Given enough eyeballs, all bugs are shallow" - Linus's Law***


- - -
### PayPal POV

```
Hello,
 
Thank you for participating in our PayPal Bug Bounty Program.
Bugs are classified according to the data impacted, ease of exploit and overall risk to PayPal customers and the PayPal brand. Your submission was found to be invalid and not actionable due to the following:

Paypal has no control over our users mishandling their personal information. Merchants/Customers sign user agreements to not expose their tokens/paswords in any way and are responsible for any losses that result.
 
We take pride in keeping PayPal the safer place for online payment.
 
Thanks,
PayPal Bug Bounty Team
```

<p align="center">
<img src="http://i.imgur.com/VNuU20s.jpg"/>
</p>

#### The Fix

There is nothing Paypal can or will do about this, the only fix is to literally contact every single person and business that has exposed credentials warning them about the risk. Before posting this publically we have already mass messaged every email in our scraped creds.csv lists but no responses yet. Will update if that changes.
