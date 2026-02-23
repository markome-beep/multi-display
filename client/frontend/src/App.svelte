<script lang="ts">
	import Displays from "./components/Displays.svelte";
	import Controls from "./components/Controls.svelte";
	import { GetIPs } from "../wailsjs/go/main/App";

	let displays = $state<string[]>();
	GetIPs(1).then((r) => {
		displays = r;
	});
</script>

<svelte:window
	ondragover={(e) => e.preventDefault()}
	ondrop={(e) => e.preventDefault()}
/>

<main
	class="bg-zinc-950 h-screen min-h-fit flex flex-col items-center gap-5 p-5 touch-none"
>
	<Controls />
	<Displays {displays} />
</main>
