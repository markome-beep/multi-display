<script lang="ts">
	import { onMount } from "svelte";
	import { OnFileDrop, EventsOn } from "../../wailsjs/runtime";
	import {
		ProcessFile,
		DebugPrint,
		FileDialog,
	} from "../../wailsjs/go/main/App";

	let { displays } = $props();
	let active: string = $state("null");

	let erroredDisp = $state<string[]>([]);
	let successDisp = $state<string[]>([]);
	let proccesingDisp = $state<string[]>([]);

	const setHover = (disp: string) => {
		active = disp;
	};

	const clearHover = () => {
		active = "null";
	};

	onMount(() => {
		OnFileDrop((_x, _y, file_paths) => {
			// If we tracked which bin was being hovered, we use it here
			if (active != "null" && file_paths.length > 0) {
				file_paths.forEach((path) => {
					ProcessFile(path, active);
				});
			}
			clearHover();
		}, true);
	});

	EventsOn("Upload_Started", (disp) => {
		erroredDisp = erroredDisp.filter((item) => item !== disp);
		successDisp = successDisp.filter((item) => item !== disp);
		proccesingDisp.push(disp);
	});

	EventsOn("Upload_Failed", (disp) => {
		proccesingDisp = proccesingDisp.filter((item) => item !== disp);
		successDisp = successDisp.filter((item) => item !== disp);
		erroredDisp.push(disp);
	});

	EventsOn("Upload_Success", (disp) => {
		proccesingDisp = proccesingDisp.filter((item) => item !== disp);
		erroredDisp = erroredDisp.filter((item) => item !== disp);
		successDisp.push(disp);
	});
</script>

<div class="w-full grow rounded-xl bg-zinc-900 p-4">
	<div class="flex flex-row h-10">
		<h2 class="text-zinc-200 text-3xl rounded-md w-fit">Displays</h2>
		<button
			class="text-zinc-200 bg-zinc-600 rounded-md h-full p-1 aspect-square ml-auto"
			onclick={() => DebugPrint("Refresh")}
		>
			<svg
				xmlns="http://www.w3.org/2000/svg"
				viewBox="0 0 640 640"
				class="h-full m-auto"
				><!--!Font Awesome Free v7.1.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2026 Fonticons, Inc.--><path
					d="M129.9 292.5C143.2 199.5 223.3 128 320 128C373 128 421 149.5 455.8 184.2C456 184.4 456.2 184.6 456.4 184.8L464 192L416.1 192C398.4 192 384.1 206.3 384.1 224C384.1 241.7 398.4 256 416.1 256L544.1 256C561.8 256 576.1 241.7 576.1 224L576.1 96C576.1 78.3 561.8 64 544.1 64C526.4 64 512.1 78.3 512.1 96L512.1 149.4L500.8 138.7C454.5 92.6 390.5 64 320 64C191 64 84.3 159.4 66.6 283.5C64.1 301 76.2 317.2 93.7 319.7C111.2 322.2 127.4 310 129.9 292.6zM573.4 356.5C575.9 339 563.7 322.8 546.3 320.3C528.9 317.8 512.6 330 510.1 347.4C496.8 440.4 416.7 511.9 320 511.9C267 511.9 219 490.4 184.2 455.7C184 455.5 183.8 455.3 183.6 455.1L176 447.9L223.9 447.9C241.6 447.9 255.9 433.6 255.9 415.9C255.9 398.2 241.6 383.9 223.9 383.9L96 384C87.5 384 79.3 387.4 73.3 393.5C67.3 399.6 63.9 407.7 64 416.3L65 543.3C65.1 561 79.6 575.2 97.3 575C115 574.8 129.2 560.4 129 542.7L128.6 491.2L139.3 501.3C185.6 547.4 249.5 576 320 576C449 576 555.7 480.6 573.4 356.5z"
				/></svg
			>
		</button>
	</div>
	<div
		class="w-full grid grid-cols-[repeat(auto-fill,minmax(200px,1fr))] gap-4 mt-4 content-start"
	>
		{#each displays as disp}
			<button
				class="aspect-square bg-zinc-600 rounded-lg cursor-pointer outline-zinc-200 flex items-center justify-center flex-col border-2 border-zinc-400"
				class:bg-red-500={erroredDisp.includes(disp)}
				class:bg-green-500={successDisp.includes(disp)}
				class:bg-zinc-600={!successDisp.includes(disp) &&
					!erroredDisp.includes(disp)}
				class:outline-dashed={disp === active}
				class:outline-4={disp === active}
				class:-outline-offset-10={disp === active}
				style="--wails-drop-target: drop;"
				onmouseenter={() => setHover(disp)}
				ondragenter={() => setHover(disp)}
				onmouseleave={clearHover}
				onclick={() => {
					FileDialog(disp);
				}}
			>
				<p class="text-zinc-200" class:hidden={disp === active}>
					Display
				</p>
				<p
					class="group-hover:hidden text-zinc-200"
					class:hidden={disp === active}
				>
					{disp.split(".").pop()}
				</p>
				<p
					class="hidden group-hover:inline text-center text-zinc-200"
					class:inline={disp === active}
				>
					Drop/Upload
				</p>
				<p
					class="hidden group-hover:inline text-center text-zinc-200"
					class:inline={disp === active}
				>
					Video File
				</p>
				<svg
					class:hidden={!successDisp.includes(disp)}
					class="h-10"
					xmlns="http://www.w3.org/2000/svg"
					viewBox="0 0 640 640"
					><!--!Font Awesome Free v7.2.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2026 Fonticons, Inc.--><path
						d="M530.8 134.1C545.1 144.5 548.3 164.5 537.9 178.8L281.9 530.8C276.4 538.4 267.9 543.1 258.5 543.9C249.1 544.7 240 541.2 233.4 534.6L105.4 406.6C92.9 394.1 92.9 373.8 105.4 361.3C117.9 348.8 138.2 348.8 150.7 361.3L252.2 462.8L486.2 141.1C496.6 126.8 516.6 123.6 530.9 134z"
					/></svg
				>
				<svg
					class:hidden={!erroredDisp.includes(disp)}
					class="h-10"
					xmlns="http://www.w3.org/2000/svg"
					viewBox="0 0 640 640"
					><!--!Font Awesome Free v7.2.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2026 Fonticons, Inc.--><path
						d="M320 64C334.7 64 348.2 72.1 355.2 85L571.2 485C577.9 497.4 577.6 512.4 570.4 524.5C563.2 536.6 550.1 544 536 544L104 544C89.9 544 76.8 536.6 69.6 524.5C62.4 512.4 62.1 497.4 68.8 485L284.8 85C291.8 72.1 305.3 64 320 64zM320 416C302.3 416 288 430.3 288 448C288 465.7 302.3 480 320 480C337.7 480 352 465.7 352 448C352 430.3 337.7 416 320 416zM320 224C301.8 224 287.3 239.5 288.6 257.7L296 361.7C296.9 374.2 307.4 384 319.9 384C332.5 384 342.9 374.3 343.8 361.7L351.2 257.7C352.5 239.5 338.1 224 319.8 224z"
					/></svg
				>
				<span
					class:hidden={!proccesingDisp.includes(disp)}
					class="loader"
				></span>
			</button>
		{/each}
	</div>
</div>

<style>
	.loader {
		transform: rotateZ(45deg);
		perspective: 1000px;
		border-radius: 50%;
		width: 48px;
		height: 48px;
		color: #fff;
	}
	.loader:before,
	.loader:after {
		content: "";
		display: block;
		position: absolute;
		top: 0;
		left: 0;
		width: inherit;
		height: inherit;
		border-radius: 50%;
		transform: rotateX(70deg);
		animation: 1s spin linear infinite;
	}
	.loader:after {
		color: #ff3d00;
		transform: rotateY(70deg);
		animation-delay: 0.4s;
	}

	@keyframes rotate {
		0% {
			transform: translate(-50%, -50%) rotateZ(0deg);
		}
		100% {
			transform: translate(-50%, -50%) rotateZ(360deg);
		}
	}

	@keyframes rotateccw {
		0% {
			transform: translate(-50%, -50%) rotate(0deg);
		}
		100% {
			transform: translate(-50%, -50%) rotate(-360deg);
		}
	}

	@keyframes spin {
		0%,
		100% {
			box-shadow: 0.2em 0px 0 0px currentcolor;
		}
		12% {
			box-shadow: 0.2em 0.2em 0 0 currentcolor;
		}
		25% {
			box-shadow: 0 0.2em 0 0px currentcolor;
		}
		37% {
			box-shadow: -0.2em 0.2em 0 0 currentcolor;
		}
		50% {
			box-shadow: -0.2em 0 0 0 currentcolor;
		}
		62% {
			box-shadow: -0.2em -0.2em 0 0 currentcolor;
		}
		75% {
			box-shadow: 0px -0.2em 0 0 currentcolor;
		}
		87% {
			box-shadow: 0.2em -0.2em 0 0 currentcolor;
		}
	}
</style>
