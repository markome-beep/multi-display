<script>
	import {
		PlayAll,
		PauseAll,
		RebootAll,
		SeekAll,
	} from "../../wailsjs/go/main/App";
	import { EventsOn } from "../../wailsjs/runtime";

	let progress = $state(0);
	let disabled = $state(false);

	EventsOn("Disable_UI", () => {
		disabled = true;
	});

	EventsOn("Enable_UI", () => {
		disabled = false;
	});
</script>

<div
	class="w-full h-24 min-h-24 rounded-xl bg-zinc-900 p-4 flex flex-row gap-4"
>
	<button
		class="bg-blue-800 hover:bg-blue-900 active:bg-blue-950 active:scale-90 disabled:cursor-progress transition-all duration-100 w-24 h-full rounded-md cursor-pointer disabled:bg-blue-900"
		onclick={RebootAll}
		{disabled}
	>
		<svg
			xmlns="http://www.w3.org/2000/svg"
			class="h-full mx-auto p-3"
			viewBox="0 0 640 640"
			><!--!Font Awesome Free v7.2.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2026 Fonticons, Inc.--><path
				d="M352 64C352 46.3 337.7 32 320 32C302.3 32 288 46.3 288 64L288 320C288 337.7 302.3 352 320 352C337.7 352 352 337.7 352 320L352 64zM210.3 162.4C224.8 152.3 228.3 132.3 218.2 117.8C208.1 103.3 188.1 99.8 173.6 109.9C107.4 156.1 64 233 64 320C64 461.4 178.6 576 320 576C461.4 576 576 461.4 576 320C576 233 532.6 156.1 466.3 109.9C451.8 99.8 431.9 103.3 421.7 117.8C411.5 132.3 415.1 152.2 429.6 162.4C479.4 197.2 511.9 254.8 511.9 320C511.9 426 425.9 512 319.9 512C213.9 512 128 426 128 320C128 254.8 160.5 197.1 210.3 162.4z"
			/></svg
		>
	</button>
	<button
		class="bg-red-800 w-24 h-full rounded-md cursor-pointer disabled:cursor-progress hover:bg-red-900 active:bg-red-950 active:scale-90 transition-all duration-100 disabled:bg-red-900"
		onclick={PauseAll}
		{disabled}
	>
		<svg
			xmlns="http://www.w3.org/2000/svg"
			class="h-full mx-auto p-3"
			viewBox="0 0 640 640"
			><!--!Font Awesome Free v7.1.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2026 Fonticons, Inc.--><path
				d="M176 96C149.5 96 128 117.5 128 144L128 496C128 522.5 149.5 544 176 544L240 544C266.5 544 288 522.5 288 496L288 144C288 117.5 266.5 96 240 96L176 96zM400 96C373.5 96 352 117.5 352 144L352 496C352 522.5 373.5 544 400 544L464 544C490.5 544 512 522.5 512 496L512 144C512 117.5 490.5 96 464 96L400 96z"
			/></svg
		>
	</button>

	<button
		class="bg-green-800 hover:bg-green-900 active:bg-green-950 active:scale-90 disabled:cursor-progress transition-all duration-100 w-24 h-full rounded-md cursor-pointer disabled:bg-green-900"
		onclick={PlayAll}
		{disabled}
	>
		<svg
			xmlns="http://www.w3.org/2000/svg"
			class="h-full mx-auto p-3"
			viewBox="0 0 640 640"
			><!--!Font Awesome Free v7.1.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2026 Fonticons, Inc.--><path
				d="M187.2 100.9C174.8 94.1 159.8 94.4 147.6 101.6C135.4 108.8 128 121.9 128 136L128 504C128 518.1 135.5 531.2 147.6 538.4C159.7 545.6 174.8 545.9 187.2 539.1L523.2 355.1C536 348.1 544 334.6 544 320C544 305.4 536 291.9 523.2 284.9L187.2 100.9z"
			/></svg
		>
	</button>

	<!-- <input -->
	<!-- 	type="text" -->
	<!-- 	pattern="(\d{'{'}1,2{'}'}:)?[0-5]\d:[0-5]\d" -->
	<!-- 	placeholder="mm:ss or hh:mm:ss" -->
	<!-- 	class="invalid:border-red-800 border-2 border-zinc-400 rounded-md text-zinc-400 w-40 text-center placeholder-zinc-400" -->
	<!-- /> -->
	<div class="flex flex-row items-center grow">
		<div class="slider-wrapper">
			<input
				class="range"
				type="range"
				bind:value={progress}
				onchange={() => {SeekAll(progress)}}
			/>
			<div
				class="slider-progress"
				style={`width: ${progress}%`}
			></div>
		</div>
	</div>
</div>

<style>
	/* Wrapper to hold track and progress */
	.slider-wrapper {
		position: relative;
		width: 100%;
		height: 8px; /* same as track height */
		background: #333; /* dark track */
		border-radius: 2px;
	}

	/* Progress bar behind the slider */
	.slider-progress {
		position: absolute;
		top: 0;
		left: 0;
		height: 8px;
		background: #ff0000; /* YouTube red */
		border-radius: 4px;
		pointer-events: none; /* ignore clicks */
	}

	/* Dark theme YouTube-style range slider */
	.range {
		position: absolute;
		width: 100%;
		appearance: none;
		background: transparent; /* Let pseudo-elements handle track */
		cursor: pointer;
		/* Apply to all changed properties */
		transition: box-shadow 5s ease-out allow-discrete;
		box-shadow: none;
	}

	/* Track (WebKit browsers) */
	.range::-webkit-slider-runnable-track {
		height: 8px;
		width: 100%;
		background: #333; /* dark gray track */
		border-radius: 2px;
		transition: box-shadow 0.1s ease-out allow-discrete;
		box-shadow: none;
	}
	.range::-webkit-slider-thumb {
		-webkit-appearance: none;
		appearance: none;
		width: 10px;
		height: 20px;
		border-radius: 5px;
		background: #ff0000; /* YouTube red */
		margin-top: -7px; /* center thumb on track */
		border: none;
		transition: box-shadow 0.1s ease-out allow-discrete;
		box-shadow: none;
	}
	.range:hover::-webkit-slider-thumb {
		box-shadow: 0 0 0 6px rgba(255, 0, 0, 0.3);
	}

	.range:hover::-webkit-slider-runnable-track {
		box-shadow: 0 0 0 3px #333;
	}
</style>
