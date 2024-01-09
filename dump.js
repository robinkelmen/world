//stuff I may want to look at later but dont want to delete


const getRandomParticelPos = (particleCount) => {
    const arr = new Float32Array(particleCount * 3);
    for (let i = 0; i < particleCount; i++) {
        arr[i] = (Math.random() - 0.5) * 10;
    }
    return arr;
};

const material = new THREE.PointsMaterial({
    size: 0.05,
    color: 0x44aa88 // remove it if you want white points.
});

const geometrys = [new THREE.BufferGeometry(), new THREE.BufferGeometry()];



geometrys[0].setAttribute(
    "position",
    new THREE.BufferAttribute(getRandomParticelPos(350), 3)
);
geometrys[1].setAttribute(
    "position",
    new THREE.BufferAttribute(getRandomParticelPos(1500), 3)
);




// material
const materials = [
    new THREE.PointsMaterial({
        size: 0.05,
        transparent: true,
        color: "#ff0000"
    }),
    new THREE.PointsMaterial({
        size: 0.075,
        transparent: true,
        color: "#0000ff"
    })
];


const starsT1 = new THREE.Points(geometrys[0], materials[0]);
const starsT2 = new THREE.Points(geometrys[1], materials[1]);
scene.add(starsT1);
scene.add(starsT2);


/* const geometry = new THREE.BoxGeometry(1, 1, 1);
const material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });

const cube = new THREE.Mesh(geometry, material);
scene.add(cube); */

/* const sphgeom = new THREE.SphereGeometry(1, 32, 16);
const sphmat = new THREE.MeshBasicMaterial({ color: 0xffff00 });


const sph = new THREE.Mesh(sphgeom, sphmat);

scene.add(sph); */