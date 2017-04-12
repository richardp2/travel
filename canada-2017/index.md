---
comments: false
layout: page
title: "Trip: Canada 2017"
category: canada-2017
--- 

<ul id='archive'>{% assign sorted_posts = (site.posts | where: "categories" , page.category) %}
{% for post in sorted_posts %}
    {% include archives.html %}
{% endfor %}
</ul>