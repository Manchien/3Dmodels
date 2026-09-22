/*
Sitting on a Ledge Figurine - Simple Chibi Cat
Units: mm

Coordinate system:
  tabletop z = 0
  ledge x = 0
  tabletop inside x > 0
  hanging side x < 0

Design:
  - One simple body ellipsoid
  - One head
  - Two ears
  - Two front paws
  - Two hanging legs
  - One curled tail
*/

$fn = 48;


// ============================================================
// Parameters
// ============================================================

show_table       = true;
show_edge_line   = true;
show_com_marker  = false;

quality          = 48;

ledge_x          = 0;
safety_margin_x  = 5;


// ---------- Head ----------
head_h = 20;
head_w = 20;
head_d = 19;


// ---------- Body ----------
// Only ONE body volume
body_w = 25;   // Y direction
body_d = 27;   // X direction
body_h = 27;   // Z direction


// ---------- COM visual guide ----------
com_proxy = [8,0,17];

$fn = quality;


// ============================================================
// Vector helpers
// ============================================================

function vadd(a,b) =
[
    a[0]+b[0],
    a[1]+b[1],
    a[2]+b[2]
];

function vmul(a,s) =
[
    a[0]*s,
    a[1]*s,
    a[2]*s
];

function bez2(p0,p1,p2,t) =
    vadd(
        vadd(
            vmul(p0,(1-t)*(1-t)),
            vmul(p1,2*(1-t)*t)
        ),
        vmul(p2,t*t)
    );


// ============================================================
// Basic shapes
// ============================================================

module bio_ellipsoid(size=[10,10,10])
{
    resize(size)
        sphere(r=10, $fn=96);
}


module ball(p=[0,0,0],r=2)
{
    translate(p)
        sphere(r=r);
}


module tapered_segment(p0,p1,r0,r1)
{
    hull()
    {
        ball(p0,r0);
        ball(p1,r1);
    }
}


module bezier_limb(
    p0,
    p1,
    p2,
    r0=3,
    r1=2,
    steps=6
)
{
    for(i=[0:steps-1])
    {
        t0 = i/steps;
        t1 = (i+1)/steps;

        tapered_segment(
            bez2(p0,p1,p2,t0),
            bez2(p0,p1,p2,t1),

            r0 + (r1-r0)*t0,
            r0 + (r1-r0)*t1
        );
    }
}


// ============================================================
// Seat contact
// ============================================================

module flat_seat_contact()
{
    /*
       Flat bottom hidden inside body.

       Gives the cat a stable surface
       on the tabletop.
    */

    translate([17,0,1.2])
    minkowski()
    {
        cube(
            [22,20,0.8],
            center=true
        );

        sphere(
            r=1,
            $fn=24
        );
    }
}


// ============================================================
// BODY
// ============================================================

module cat_body()
{
    /*
       ONLY ONE body ellipsoid.

       Slightly large and round to make
       it look like a sitting cat.
    */

    translate([
        18,
        0,
        15
    ])
    bio_ellipsoid([
        body_d,
        body_w,
        body_h
    ]);
}


// ============================================================
// Head
// ============================================================

module cat_head()
{
    /*
       Chibi-style large head.
    */

    translate([
        15,
        0,
        37
    ])
    bio_ellipsoid([
        head_d,
        head_w,
        head_h
    ]);
}


// ============================================================
// Ears
// ============================================================

module cat_ear(side=1)
{
    /*
       Simple rounded triangular ear.
    */

    hull()
    {
        // inner bottom
        ball(
            [14.5,side*5.3,43],
            3
        );

        // ear tip
        ball(
            [15.5,side*7.3,49],
            1.4
        );

        // outer bottom
        ball(
            [19,side*5.8,43],
            2.6
        );
    }
}


// ============================================================
// Face
// ============================================================

module face_relief()
{
    // Eyes

    for(side=[-1,1])
    {
        translate([
            5.8,
            side*3.5,
            39
        ])

        rotate([0,90,0])

        cylinder(
            h=1.2,
            r=1.05,
            center=true
        );
    }


    // Nose

    translate([
        5.4,
        0,
        36
    ])

    rotate([0,90,0])

    cylinder(
        h=1.2,
        r=0.7,
        center=true
    );


    // Mouth

    translate([
        5.6,
        0,
        34.7
    ])

    rotate([0,90,0])

    cylinder(
        h=1.0,
        r=0.45,
        center=true
    );
}


// ============================================================
// Hanging back legs
// ============================================================

module hanging_leg(side=1)
{
    /*
       短短胖胖的垂腿
    */

    p0 = [
        8.5,
        side*6.8,
        12.5
    ];

    p1 = [
        3.0,
        side*7.0,
        6.0
    ];

    p2 = [
        -2.5,
        side*7.0,
        -3.5
    ];


    bezier_limb(
        p0,
        p1,
        p2,
        4.2,   // 上端更粗
        3.6,   // 下端也不要太細
        6
    );


    // 圓胖腳掌
    hull()
    {
        ball(
            [-2.5, side*7.0, -3.5],
            3.8
        );

        ball(
            [-6.2, side*7.0, -4.5],
            4.3
        );
    }
}

// ============================================================
// Front paws
// ============================================================

module front_paw(side=1)
{
    // 肩膀到手臂
    hull()
    {
        // 肩膀（接身體兩側）
        ball([15, side*10, 24], 3.2);

        // 手肘（往外、往上）
        ball([11, side*14, 30], 2.8);
    }

    // 前臂到手掌
    hull()
    {
        ball([11, side*14, 30], 2.8);

        // 手掌位置：歡呼狀，舉高
        ball([9, side*15.5, 36], 3.8);
    }

    // 圓圓的手掌（像哆啦A夢）
    ball([9, side*15.5, 36], 4.2);
}


// ============================================================
// Tail
// ============================================================

module curled_tail()
{
    /*
       Simple curved tail.

       Made from only a few connected
       spheres instead of a complicated
       logarithmic spiral.
    */

    hull()
    {
        ball([27,-8,12],2.7);
        ball([31,-10,13],2.5);
    }

    hull()
    {
        ball([31,-10,13],2.5);
        ball([33,-11,17],2.3);
    }

    hull()
    {
        ball([33,-11,17],2.3);
        ball([31,-11,21],2.0);
    }

    hull()
    {
        ball([31,-11,21],2.0);
        ball([28,-10,21],1.7);
    }
}


// ============================================================
// Complete cat
// ============================================================

module chibi_cat()
{
    difference()
    {
        union()
        {
            // Stable flat bottom
            flat_seat_contact();


            // ------------------------
            // ONLY ONE BODY
            // ------------------------

            cat_body();


            // Head
            cat_head();


            // Ears
            cat_ear(-1);
            cat_ear(1);


            // Back legs
            hanging_leg(-1);
            hanging_leg(1);


            // Front paws
            front_paw(-1);
            front_paw(1);


            // Tail
            curled_tail();
        }


        // Face
        face_relief();


        /*
           Remove anything below tabletop
           on the inside/front area to
           reduce unwanted rocking.
        */

        translate([
            -10,
            0,
            0.4
        ])

        cube(
            [18,40,1],
            center=true
        );
    }
}


// ============================================================
// CAT
// ============================================================

color([
    0.92,
    0.72,
    0.58
])
chibi_cat();


// ============================================================
// Table
// ============================================================

if(show_table)
{
    color([
        0.72,
        0.76,
        0.80,
        0.35
    ])

    translate([
        35,
        0,
        -1.25
    ])

    cube(
        [70,80,2.5],
        center=true
    );
}


// ============================================================
// Edge line
// ============================================================

if(show_edge_line)
{
    // Table edge
    color("red")

    translate([
        ledge_x,
        0,
        0.15
    ])

    cube(
        [0.6,76,0.6],
        center=true
    );


    // Safety line
    color([
        0.2,
        0.5,
        1.0,
        0.25
    ])

    translate([
        safety_margin_x,
        0,
        0.25
    ])

    cube(
        [0.4,30,0.5],
        center=true
    );
}


// ============================================================
// COM marker
// ============================================================

if(show_com_marker)
{
    color("lime")

    translate(com_proxy)

    sphere(r=1.8);


    color("lime")

    translate([
        com_proxy[0],
        com_proxy[1],
        0
    ])

    cylinder(
        h=com_proxy[2],
        r=0.35
    );
}


// ============================================================
// Diagnostics
// ============================================================

echo(
    "Body volumes = 1"
);

echo(
    "Body size = ",
    [body_d,body_w,body_h]
);

echo(
    "COM proxy X = ",
    com_proxy[0],
    " mm"
);