#!/usr/bin/perl

use warnings;
use strict;

=begin comment

    stopwatch.pl - A simple stopwatch just for minutes and seconds.

    Copyright (C) 2020 hlubenow

    This program is free software: you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

=end comment

=cut

use Tk;

package Controller {

    sub new {
        my $classname = shift;
        my $self = {};
        return bless($self, $classname);
    }

    sub startApplication {
        my $self = shift;
        $self->{model} = Model->new($self);
        $self->{view}  = View->new($self);
        $self->{watch_running} = 0;
        $self->{view}->startApplication();
    }

    sub startstop {
        my $self = shift;
        if ($self->{watch_running} == 0) {
            $self->{watch_running} = 1;
            $self->{model}->startWatch();
            $self->{view}->disableContinueButton();
            $self->{view}->setButtonText($self->{watch_running});
            $self->{view}->startWatch($self->{model}->{timestring});
            return;
        }
        if ($self->{watch_running} == 1) {
            $self->{watch_running} = 0;
            $self->{model}->storeStopTime();
            $self->{view}->activateContinueButton();
            $self->{view}->setButtonText($self->{watch_running});
            $self->{view}->updateTime($self->{model}->{timestring});
        }
    }

    sub continue {
        my $self = shift;
        $self->{watch_running} = 1;
        $self->{model}->storeDelay();
        $self->{view}->setButtonText($self->{watch_running});
        $self->updateTime();
    }

    sub updateTime {
        my $self = shift;
        $self->{model}->updateTime();
        $self->{view}->updateTime($self->{model}->{timestring});
    }
}

package Model {

    sub new {
        my $classname = shift;
        my $self = {};
        $self->{controller} = shift;
        return bless($self, $classname);
    }

    sub startWatch {
        my $self = shift;
        $self->{starttime} = time();
        $self->{stop_time} = 0;
        $self->{delays}    = [];
        $self->updateTime();
    }

    sub storeStopTime {
        my $self = shift;
        $self->{stop_time} = time();
    }

    sub storeDelay {
        my $self = shift;
        push($self->{delays}, time() - $self->{stop_time});
    }

    sub updateTime {
        my $self = shift;
        $self->{secs} = time() - $self->{starttime};
        for my $i (@{$self->{delays}}) {
            $self->{secs} -= $i;
        }
        if ($self->{secs} >= 3600) {
            $self->startWatch();
        }
        my $mins = $self->{secs} / 60;
        my $secs = $self->{secs} % 60;
        $self->{timestring} = sprintf("%.2d", $mins);
        $self->{timestring} .= ":";
        $self->{timestring} .= sprintf("%.2d", $secs);
    }
}

package View {

    sub new {
        my $classname = shift;
        my $self = {};
        $self->{controller} = shift;
        $self->{mainfont}   = "{Sans} 15 {normal}";
        $self->{watchfont}  = "{Sans} 28 {normal}";
        return bless($self, $classname);
    }

    sub startApplication {
        my $self = shift;
        $self->{mw} = Tk::MainWindow->new(-title => "Stopwatch");
        $self->{mw}->optionAdd("*font", $self->{mainfont});
        $self->{mw}->geometry("400x200+430+200");
        $self->{mw}->bind("<Control-q>" => sub { $self->endApplication(); });

        $self->{entr1} = $self->{mw}->Entry(-background => "white",
                                            -foreground => "black",
                                            -takefocus  => 0,
                                            -width      => 6,
                                            -font       => $self->{watchfont});
        $self->{entr1}->insert(0, " 00:00");
        $self->{entr1}->pack(-pady => 50);

        $self->{frame1} = $self->{mw}->Frame();
        $self->{btn1} = $self->{frame1}->Button(-text => " Start ",
                                                -command => sub { $self->{controller}->startstop(); });
        $self->{btn1}->focus();
        $self->{btn1}->pack(-side => "left", -ipadx => 0, -padx => 10);
        $self->{btn2} = $self->{frame1}->Button(-text => "Continue",
                                                -command => sub { $self->{controller}->continue(); });
        $self->{btn2}->pack(-side => "left", -padx => 10);
        $self->disableContinueButton();
        $self->{btn3} = $self->{frame1}->Button(-text => "Exit",
                                                -takefocus  => 0,
                                                -command => sub { $self->endApplication(); });
        $self->{btn3}->pack(-side => "left", -ipadx => 15, -padx => 35);
        $self->{frame1}->pack(-padx => 50, -pady => 20);
        Tk::MainLoop();
    }

    sub setButtonText {
        my $self = shift;
        my $running = shift;
        if ($running) {
            $self->{btn1}->configure(-text => "  Stop ");
        } else {
            $self->{btn1}->configure(-text => "Restart");
        }
    }

    sub disableContinueButton {
        my $self = shift;
        $self->{btn2}->configure(-state => "disabled");
    }

    sub activateContinueButton {
        my $self = shift;
        $self->{btn2}->configure(-state => "normal");
    }


    sub startWatch {
        my $self = shift;
        my $timestring = shift;
        $self->updateTime($timestring);
    }

    sub updateTime {
        my $self = shift;
        my $timestring = shift;
        $timestring = " $timestring ";
        $self->{entr1}->delete(0, "end");
        $self->{entr1}->insert(0, $timestring);
        if ($self->{controller}->{watch_running}) {
            $self->{mw}->after(100, sub { $self->{controller}->updateTime(); } );
        }
    }

    sub endApplication {
        my $self = shift;
        $self->{mw}->destroy();
    }
}

my $c = Controller->new();
$c->startApplication();
