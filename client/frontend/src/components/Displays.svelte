<script lang="ts">
	import { onMount } from "svelte";
	import { OnFileDrop, EventsOn } from "../../wailsjs/runtime";
	import {
		ProcessFile,
		LoadVideoAll,
		FileDialog,
	} from "../../wailsjs/go/main/App";

	let disabled = $state(false);

	EventsOn("Disable_UI", () => {
		disabled = true;
	});

	EventsOn("Enable_UI", () => {
		disabled = false;
	});

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

	EventsOn("Upload_Clear", (disp) => {
		proccesingDisp = proccesingDisp.filter((item) => item !== disp);
		erroredDisp = erroredDisp.filter((item) => item !== disp);
		successDisp = successDisp.filter((item) => item !== disp);
	});
</script>

<div class="w-full grow rounded-xl bg-zinc-900 p-4">
	<div class="flex flex-row h-10">
		<h2 class="text-zinc-200 text-3xl rounded-md w-fit">Displays</h2>

		<button
			class="text-zinc-200 bg-zinc-500 hover:bg-zinc-600 disabled:bg-zinc-600 cursor-pointer disabled:cursor-progress active:bg-zinc-700 active:scale-90 rounded-md h-full p-1 aspect-square ml-auto transition-all duration-100"
			onclick={LoadVideoAll}
			{disabled}
		>
			<svg
				xmlns="http://www.w3.org/2000/svg"
				viewBox="0 0 640 640"
				class="h-full m-auto"
				><!--!Font Awesome Free v7.2.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2026 Fonticons, Inc.--><path
					d="M128 128C128 92.7 156.7 64 192 64L341.5 64C358.5 64 374.8 70.7 386.8 82.7L493.3 189.3C505.3 201.3 512 217.6 512 234.6L512 512C512 547.3 483.3 576 448 576L192 576C156.7 576 128 547.3 128 512L128 128zM336 122.5L336 216C336 229.3 346.7 240 360 240L453.5 240L336 122.5zM208 368L208 464C208 481.7 222.3 496 240 496L336 496C353.7 496 368 481.7 368 464L368 440L403 475C406.2 478.2 410.5 480 415 480C424.4 480 432 472.4 432 463L432 368.9C432 359.5 424.4 351.9 415 351.9C410.5 351.9 406.2 353.7 403 356.9L368 391.9L368 367.9C368 350.2 353.7 335.9 336 335.9L240 335.9C222.3 335.9 208 350.2 208 367.9z"
				/></svg
			>
		</button>
	</div>
	<div
		class="w-full grid grid-cols-[repeat(auto-fill,minmax(200px,1fr))] gap-4 mt-4 content-start"
	>
		{#each displays as disp}
			<button
				class="aspect-square bg-zinc-600 rounded-lg cursor-pointer outline-zinc-200 flex items-center justify-center flex-col border-2 border-zinc-400 disabled:cursor-progress"
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
				{disabled}
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
