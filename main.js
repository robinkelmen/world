import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
import { BloomPass } from 'three/addons/postprocessing/BloomPass.js';
import { OutputPass } from 'three/addons/postprocessing/OutputPass.js';
import { Universe } from './universe.js';
import { CelestialBody } from './celestialbody.js';
import Stats from 'three/examples/jsm/libs/stats.module'
import { GUI } from 'dat.gui'

import fragment from './shaders/fragment.glsl?raw';
import vertex from './shaders/vertex.glsl?raw';

let seamlessU = false;
let seamlessV = false;


const loader = new GLTFLoader();
const textLoader = new THREE.TextureLoader();

let clock = new THREE.Clock();
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 100000);


//renderer settings
const renderer = new THREE.WebGLRenderer();
renderer.setClearColor(new THREE.Color("#1c1624"));
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);


const controls = new OrbitControls(camera, renderer.domElement);
controls.target.set(0, 0, 0);
controls.enableZoom = true;










const bodies = [];
const scaleFactor = 1e-8;


const G = 0.0000005;
const un = new Universe(G);

function calculateOrbitalVelocity(radius) {
    return Math.sqrt(G * 1.989e30 / radius); // Mass of the Sun is 1.989e30 kg
}

const sunMass = 10; // 1 kg (for visualization)
const earthMass = 10; // Mass of Earth in kg, scaled down



// Sun (at origin with zero initial velocity)



let uniforms = {
    uTexture: {
        value: textLoader.load("./textures/suntex.png")
    },
    uTime: { value: 0 },
    seamlessU: { value: false },
    seamlessV: { value: false }


};

const sunRadius = 10;
const sunGeometry = new THREE.IcosahedronGeometry(5, 150);
const sunMaterial = new THREE.ShaderMaterial(
    {

        uniforms: uniforms,
        vertexShader: vertex,
        fragmentShader: fragment
    }
);

const sun = new CelestialBody(sunMass, 1, new THREE.Vector3(0, 0, 0), new THREE.Vector3(0, 0, 0), un, 0xffff00, { geometry: sunGeometry, material: sunMaterial }, "Sun");
bodies.push(sun);
scene.add(sun);

// Adjusted distances and sizes for the planets to make them fit within the screen
const earthDistanceFromSun = 10; // Adjusted distance
const earthVelocity = calculateOrbitalVelocity(earthDistanceFromSun);
const earth = new CelestialBody(earthMass, 1, new THREE.Vector3(20, 0, 0), new THREE.Vector3(0.0005, 0, 0), un, 0x00ff00, null, "Earth");
bodies.push(earth);
scene.add(earth);



camera.position.z = 30; // Adjusted zoom to see the scaled-down solar system
controls.target.set(0, 0, 0); // Set the target to the center of the solar system




/* const timeStep = 5; // 1 day in seconds (adjust as needed)
bodies.forEach(body => {
    body.updateVelocity(bodies, timeStep);
    body.updatePosition(timeStep);
}); */

const stats = new Stats()
document.body.appendChild(stats.dom)

const gui = new GUI()
const cubeFolder = gui.addFolder('Sun')
cubeFolder.add(sunMaterial.uniforms.seamlessU, 'value', false, true);
cubeFolder.add(sunMaterial.uniforms.seamlessV, 'value', false, true);

cubeFolder.open()


let startTime = performance.now();

function animate() {
    requestAnimationFrame(animate);

    render();



}

seamlessV = true;
seamlessU = true;
function render() {




    // Update the time in a smooth manner based on elapsed time (adjust the scale factor as needed)
    const smoothTime = clock.getElapsedTime() * 0.1; // Convert milliseconds to seconds

    // Update the uTime uniform with the smooth time
    sunMaterial.uniforms.uTime.value = smoothTime;
    //sunMaterial.uniforms.seamlessU.value = seamlessU;
    //sunMaterial.uniforms.seamlessV.value = seamlessV;

    // Update controls
    controls.update();

    renderer.render(scene, camera);
}
animate();