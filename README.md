VCode-QMAT
==========

A fork of http://code.google.com/p/vcode/ to get it annotating how we* need it.

* which is to say Toby, for comedy lab http://tobyz.net/projects/comedylab

Broadly speaking that's currently:
- Annotations can come from a controlled vocabulary and are continuous, ie. non-overlapping
- Annotating can be done in one-pass with one hand on keyboard and one on scroll-gesture mouse/trackpad

Changelog:
- Added annotation menu with keyboard shortcuts for annotation tasks
- Made much more keyboard and mouse savvy, including concept of currently selected annoation
- Added the controlled vocabulary to the annotation menu (to be loaded in dynamically for use beyond comedy lab)
- Ranged track annotations are now continuous, ie. non-overlapping (should be a track option for use beyond comedy lab)
- JKL playback control for fast navigation through video and holding play speed to something other than 1x when play/pausing with spacebar
- Track display reworked 
  - to show annotation text in the annotation range
  - outline shows whether annotated, not-annotated, or currently selected
