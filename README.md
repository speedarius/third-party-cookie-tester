third-party-cookie-tester
=========================

A basic Rails app to test web browsers' third-party cookie-blocking behavior.

I couldn't find authoritative information on how Safari treats 'third-party' cookies when set to "From visited" (mobile) or "Block from third-parties and advertisers" (desktop), so I created this simple rails app to test several scenarios.

How to use it
-------------

1. Create these fake hosts in your `/etc/hosts`:

        127.0.0.1 a.com b.com c.com a.b.com a.com b.b.com

2. Start the server: `rails server -p <some_port>`

3. Visit some of the following paths on any of the fake hosts:

* `/`
Visit the host without setting any cookies at all, not even a rails default session cookie. Shows the cookies that the browser sent to the server; this is a good way to tell if cookies have been set on a particular domain. I've found that various in-browser cookie-inspection tools are not good about excluding cookies that have been blocked via third-party cookie-blocking features.

* `/happy-cookie`
Visit the domain, setting a (first-party) from that host.

* `/third-party-script-tags`
Visit the domain and request (third-party) cookie-setting assets from each host via `<script>` tags.

* `/third-party-iframes`
Visit the domain and request (third-party) cookie-setting assets from each host via iframes.

* `/redirect?target=<url>`
Visit the domain and get redirected to the target URL.

* `/iframe?target=<url>&hidden=<hidden>`
Visit the domain and open an iframe to the target URL. Accepts a 'hidden' param, which will cause the iframe to be a 1x1, with "display:none".

* `/open_window?target=<url>`
Visit the domain, then open a new window to the target URL.

For instance, `http://a.b.com:<some_port>/redirect?target=http://c.com:<some_port>/third_parties` will try to set third party cookies on each of `a.b.com`, `b.com`, and `c.com`, in the context of `c.com`, via redirect from `a.b.com`. To see if Safari accepts a third party cookie from `a.b.com` in this scenario, visit `http://a.b.com:<some_port>` and look for the `third_party` cookie in the list of received cookies. (It doesn't.)


Findings
----------
I investigated the behavior in mobile Safari (iOS 6.1(10B141)), desktop Safari (Version 7.0.4 (9537.76.4)) and Chrome (Version 35.0.1916.153). This is a summary of what I found:

* **Safari.** The feature is enabled by default. An exception is made for third-party cookies on domains where the browser already has a cookie set. So if the browser already has a cookie on say "track.com", the browser will allow further cookies to be set on "track.com", even in a third-party context. There is no difference I'm aware of between desktop Safari and Mobile Safari.

* **Chrome.** The feature is not enabled by default. There is no exception made for pre-existing cookies on a given domain. Further, when requesting a third-party asset where the browser already has a cookie on the domain, the pre-existing cookie is not even sent along with the request for the third-party asset.

* **Redirects.** When the browser follows a chain of redirects, the final request in the chain is considered to be the first-party. It doesn't matter if the initial request was on a different domain.

* **Popup windows / tabs.** Popup windows and tabs are top-level documents with their own first-party domains. If a page on domain A opens a pop-up on domain B, domain B will be permitted to set cookies within that window.

* **Iframes.** Iframes are considered to be secondary assets; their hosts are third-parties unless they match the domain of the parent document.

* **script assets.** Like iframes, are considered to be secondary assets; their hosts are third parties unless they match the domain of the parent document.

* **Subdomains.** For both Chrome and Safari, "b.com" and "b.b.com" are both considered first-parties in the context of "a.b.com".
