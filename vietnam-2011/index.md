---
comments: false
layout: page
title: "Trip: Vietnam 2011"
category: vietnam-2011
redirect_from:
  - /vietnam/hanoi/vietnam-2011/
  - /vietnam/ha-long-bay/vietnam-2011/
  - /vietnam/hội-an/vietnam-2011/
  - /vietnam/huế/vietnam-2011/
---

<ul id='archive'>{% assign sorted_posts = site.posts | where: "categories" , page.category %}
{% for post in sorted_posts %}
    {% include archives.html %}
{% endfor %}
</ul>
