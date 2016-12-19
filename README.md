aasm_statecharts
================

`aasm_statecharts` is a utility for generating UML statechart diagrams from state machines defined using [AASM](https://github.com/aasm/aasm). Unlike other state diagram generators, it can express extended finite state machine concepts such as guards and entry actions.

**Note:**  This fork is updated to work with **rails 5** and **aasm 4**.  This will **not** work with aasm < 4.0

Requirements
------------
- rails >= 5.0
- aasm >= 4.0
- ruby-graphviz >= 1.0


Installation and Invokation
---------------------------

You can install `aasm_statecharts` from RubyGems using `gem install aasm_statecharts`, or add the `aasm_statecharts` gem to your Gemfile and run Bundler to install it.

If you have installed `aasm_statecharts` via gem, you can invoke it using the command `aasm_statecharts`; otherwise, if you have used Bundler without generating binstubs, you can invoke it with the command `bundle exec aasm_statecharts`. The following assumes that it has been installed via gem for simplicity.

Example
-------

Considuer following model, which is assumed to be stored in `app/models/claim.rb`:
```rb
class Claim < ActiveRecord::Base
  belongs_to :user
  validates :title, presence: true
  validates :description, presence: true

  include AASM

  aasm do
    state :unsubmitted, initial: true
    state :submitted, exit: [:cancel_deadline, :close_ticket]
    state :resolved, final: true

    event :submit do
      transitions from: :unsubmitted, to: :submitted,
                  guard: :accepting_claims?,
                  on_transition: :notify_submitted
    end
    event :return do
      transitions from: :submitted, to: :unsubmitted
    end
    event :accept do
      transitions from: :submitted, to: :resolved
    end
  end
  
  def accepting_claims?
  end
  
  def cancel_deadline
  end

  def close_ticket
  end
  
  def notify_submitted
  end
end
```

If we invoke `aasm_statecharts claim`, then the following diagram will be written to ./doc/claim.png:

![Claim Statechart](https://raw.githubusercontent.com/WorkflowsOnRails/aasm_statecharts/master/doc/claim.png)


Usage
-----

For more advanced usage information, see `aasm_statecharts --help`:

    Usage: aasm_statecharts [options] <model> [models ...]
        -a, --all                        Render all models using AASM
        -d, --directory directory        Output to a specific directory (default: ./doc)
        -t, --file-type type             Output in the specified format (default: png),
    which must be one of the following: bmp, canon, dot, xdot, cmap, dia, eps, fig, gd,
    gd2, gif, gtk, hpgl, ico, imap, cmapx, imap_np, cmapx_np, ismap, jpeg, jpg, jpe, mif,
    mp, pcl, pdf, pic, plain, plain-ext, png, ps, ps2, svg, svgz, tga, tiff, tif, vml,
    vmlz, vrml, vtx, wbmp, xlib, none.
