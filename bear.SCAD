/*
    Chibi Bear + Foot Mount C Clip
    Units: mm

    需求：
    - Q版熊
    - 身體小一點、圓一點
    - 有尾巴
    - C卡槽在腳底，不在屁股
    - 盡量避免懸空，適合直接列印
*/

$fn = 80;


// =========================
// Parameters
// =========================

// --- 後照鏡桿 / 支架直徑 ---
rod_d = 10;          // 要卡住的桿子直徑
clip_wall = 3;       // 卡槽壁厚
clip_depth = 10;     // 卡槽厚度（Z方向高度）
clip_gap = 5;        // C開口寬度

// --- 腳底連接底座 ---
foot_plate_w = 22;   // 腳底底座左右寬
foot_plate_d = 18;   // 腳底底座前後深
foot_plate_h = clip_depth;  // 和卡槽一樣高，直接從底部長起來

// --- 熊 ---
head_w = 28;
head_d = 24;
head_h = 26;

ear_size = 6;

body_w = 20;
body_d = 18;
body_h = 20;

arm_d = 7;

leg_w = 9;
leg_d = 10;
leg_h = 8;

tail_d = 8;


// =========================
// Main
// =========================

union() {
    foot_mount();   // 腳底底座 + C卡槽
    bear();         // 熊本體
}


// =========================
// 腳底底座 + C卡槽
// =========================

module foot_mount() {

    union() {

        // 腳底底座：讓熊直接站在上面
        translate([
            -foot_plate_w/2,
            -foot_plate_d/2,
            0
        ])
        cube([
            foot_plate_w,
            foot_plate_d,
            foot_plate_h
        ]);

        // C型卡槽：放在腳底正中央
        translate([0, 0, 0])
        linear_extrude(height = clip_depth)
        c_clip_2d();
    }
}


// =========================
// 2D C Clip
// =========================

module c_clip_2d() {

    outer_d = rod_d + clip_wall * 2;

    difference() {

        // 外圈
        circle(d = outer_d);

        // 內孔
        circle(d = rod_d);

        // C型開口
        // 現在開口朝「前方(Y負方向)」
        translate([0, -outer_d/2])
        square([
            clip_gap,
            outer_d
        ], center = true);
    }
}


// =========================
// Bear
// =========================

module bear() {

    union() {
        body();
        head();
        ears();
        arms();
        legs();
        tail();
        muzzle();
    }
}


// =========================
// Body
// =========================

module body() {

    // 熊的最低點建立在腳底底座上方
    z0 = foot_plate_h;

    hull() {

        // 下半身
        translate([0, 0, z0 + 9])
        scale([9.5, 8.5, 8.5])
        sphere(1);

        // 肚子
        translate([0, 0, z0 + 17])
        scale([10, 9, 9.5])
        sphere(1);

        // 上半身
        translate([0, 0, z0 + 25])
        scale([8.5, 7.5, 7.5])
        sphere(1);
    }
}


// =========================
// Head
// =========================

module head() {

    z0 = foot_plate_h;

    translate([0, 0, z0 + 36])
    scale([
        head_w/2,
        head_d/2,
        head_h/2
    ])
    sphere(1);
}


// =========================
// Ears
// =========================

module ears() {

    z0 = foot_plate_h;

    translate([-10, 0, z0 + 47])
    scale([ear_size, ear_size*0.8, ear_size])
    sphere(1);

    translate([10, 0, z0 + 47])
    scale([ear_size, ear_size*0.8, ear_size])
    sphere(1);
}


// =========================
// Arms
// =========================

module arms() {

    z0 = foot_plate_h;

    // 左手
    hull() {
        translate([-8.5, 0, z0 + 24])
        sphere(d = arm_d);

        translate([-14, 0, z0 + 18])
        sphere(d = arm_d * 1.1);
    }

    // 右手
    hull() {
        translate([8.5, 0, z0 + 24])
        sphere(d = arm_d);

        translate([14, 0, z0 + 18])
        sphere(d = arm_d * 1.1);
    }
}


// =========================
// Legs
// =========================

module legs() {

    z0 = foot_plate_h;

    // 左腳
    translate([-6.2, -1, z0 + 3.5])
    scale([
        leg_w/2,
        leg_d/2,
        leg_h/2
    ])
    sphere(1);

    // 右腳
    translate([6.2, -1, z0 + 3.5])
    scale([
        leg_w/2,
        leg_d/2,
        leg_h/2
    ])
    sphere(1);
}


// =========================
// Tail
// =========================

module tail() {

    z0 = foot_plate_h;

    // 小尾巴在背後下方
    translate([0, 8, z0 + 12])
    sphere(d = tail_d);
}


// =========================
// Muzzle
// =========================

module muzzle() {

    z0 = foot_plate_h;

    // 嘴巴
    translate([0, -11, z0 + 33])
    scale([6.5, 3.8, 4.8])
    sphere(1);

    // 鼻子
    translate([0, -14, z0 + 35])
    scale([3.0, 1.8, 2.2])
    sphere(1);
}