# middleman-bem-html

A Middleman extension to add BEM classes to HTML based on HTML attributes. 

Makes use of [bem_html](https://github.com/oncomouse/bem_html) to handle class generation and [css_dead_class](https://github.com/oncomouse/css_dead_class) to cleanup unused CSS classes.

## Purpose

In large projects, BEM namespacing can get fairly complicated. In Sass and PostCSS, there exist a number of helper methods to simply the creation of nested Block, Element, Modifier classes; however, this plugin provides similar helper methods within HTML itself.

## Sample Usage

Say you had a BEM block called "widget" that had the following structure in HTML:

~~~html

<div class="widget">
	<h1 class="widget__heading widget__heading--lime">Heading</h1>
	<section class="widget__content">
		<p class="widget__content__first-paragraph">First Paragraph</p>
	</section>
</div>
~~~

With bem-html, you could define that structure instead as the following:

~~~html
<div bem-block="widget">
	<h1 bem-element="heading" modifiers="[:lime]">Heading</h1>
	<section bem-element="content">
		<p bem-element="first-paragraph">First Paragraph</p>
	</section>
</div>
~~~

And this extension would produce the desired HTML.

Originally, this extension was specifically designed for HAML, where it really shines:

~~~haml
%div{bem:{block: :widget}}
	%h1{bem:{element: :heading, modifiers: [:lime]}} Heading
	%section{bem:{element: :content}}
		%p{bem: {element: "first-paragraph"}} First Paragraph
~~~

## Installation

Add

~~~
gem "middleman-bem-html"
~~~

to your `Gemfile` and run `bundle update`

## Configuration

In `config.rb`, add the following:

~~~ruby
activate :bem_html

config[:classes_to_keep] = [
	'no-js',
]
config[:internal_css] = true
~~~

The two configuration options are:

### `:classes_to_keep`

An array of CSS class names to not remove, even if they are not present in any of the CSS files.

### `:internal_css`

**defaults to `true`**

If you are using any `external_pipeline` calls to configure your CSS files (like gulp or PostCSS), the `after_build` method that this extension uses to remove all the unused CSS from production HTML will run before the CSS has been generated (as `external_pipeline` calls always run *after* extension methods).

If this effects you, please consider using [postcss-deadclass](https://github.com/oncomouse/postcss-deadclass) to remove the unused CSS classes using PostCSS.
